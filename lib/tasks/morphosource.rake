require 'morphosource'
require 'ms1to2'
require 'importer'

namespace :morphosource do

  # Loosely adapted from https://github.com/curationexperts/nurax/blob/master/lib/tasks/nurax.rake
  # Hyrax's CharacterizeJob performs file characterization and then queues up CreativeDerivativesJob.
  desc 'Loop over all FileSets, (re-)characterize the files, and (re-)generate derivatives'
  task :characterize_and_generate_derivatives => :environment do
    FileSet.find_each do |fs|
      if fs.original_file.nil?
        Rails.logger.warn("No :original_file relation returned for FileSet (#{fs.id})" )
        next
      end
      wrapper = JobIoWrapper.find_by(file_set_id: fs.id)
      path_hint = wrapper.uploaded_file ? wrapper.uploaded_file.uploader.path : wrapper.path
      Rails.logger.debug("(Re-)characterizing files and (re-)generating derivatives for FileSet #{fs.id} in the background")
      CharacterizeJob.perform_later(fs, fs.original_file.id, path_hint)
    end
  end

  # Loosely adapted from https://github.com/curationexperts/nurax/blob/master/lib/tasks/nurax.rake
  # Performs CreateDerivativesJob independently of CharacterizeJob.
  desc 'Loop over all FileSets and (re-)generate derivatives'
  task :generate_derivatives => :environment do
    FileSet.find_each do |fs|
      if fs.original_file.nil?
        Rails.logger.warn("No :original_file relation returned for FileSet (#{fs.id})" )
        next
      end
      wrapper = JobIoWrapper.find_by(file_set_id: fs.id)
      path_hint = wrapper.uploaded_file ? wrapper.uploaded_file.uploader.path : wrapper.path
      Rails.logger.debug("(Re-)generating derivatives for FileSet #{fs.id} in the background")
      CreateDerivativesJob.perform_later(fs, fs.original_file.id, path_hint)
    end
  end

  desc "switch logger to stdout"
  task :to_stdout => [:environment] do
    Rails.logger = Logger.new(STDOUT)
  end

  desc 'Loop over all FileSets and determine how many are missing derivatives'
  task :check_derivatives => :environment do
    Rails.logger.info("#{Media.count} Media works deposited, #{FileSet.count} FileSets deposited")
    
    n = 0
    FileSet.find_each do |fs|
      next if !fs.original_file.presence
      m = fs.parents&.first
      media_type = m&.media_type&.first
      derivatives = Morphosource::DerivativePath.derivatives_for_reference(fs)
      if derivatives.length == 0
        Rails.logger.warn("FileSet ID #{fs.id} (Media work ID #{m&.id.to_s}, media type #{media_type.to_s}) with mime type #{fs.mime_type} has no derivatives")
        n += 1
      elsif media_type == "CTImageSeries"
        derivatives.each do |d|
          if File.exists?(d)
            if File.extname(d).downcase == '.aleph'
              missing = []
              dcm_path = File.join(File.dirname(d), File.basename(d)[0])
              JSON.parse(File.read(d))["series"].each do |dcm|
                missing << File.basename(dcm) if !File.file?(File.join(dcm_path, File.basename(dcm)))
              end
              if missing.presence
                Rails.logger.warn("FileSet ID #{fs.id} (Media work ID #{m&.id.to_s}, media type #{media_type.to_s}) with mime type #{fs.mime_type} has manifest derivative, but #{missing.length} sub-derivative .dcm files are absent: #{missing.join(', ')}")
                n += 1
              end
            end
          else
            Rails.logger.warn("FileSet ID #{fs.id} (Media work ID #{m&.id.to_s}, media type #{media_type.to_s}) with mime type #{fs.mime_type} should have derivative, but derivative file does not exist")
            n += 1
          end
        end
      end
    end
    Rails.logger.warn("#{n} FileSets lack derivatives or have derivative issues")
  end

  desc 'Loop over media and check how many lack FileSets or have FileSets without original_file'
  task :check_file_ingests => :environment do
    Rails.logger.info("#{Media.count} Media works deposited, #{FileSet.count} FileSets deposited")

    n = 0
    Media.find_each do |m|
      media_type = m&.media_type&.first
      if !m.file_sets.presence
        Rails.logger.warn("Media work ID #{m&.id.to_s} (media type #{media_type.to_s}) has no FileSets")
        n += 1
      else
        fs_error = false
        
        m.file_sets.each do |fs|
          if !fs.original_file.presence
            Rails.logger.warn("Media work ID #{m&.id.to_s} (media type #{media_type.to_s}) has FileSet (ID: #{fs.id}), but FileSet lacks original_file")
            fs_error = true
          end
        end

        n += 1 if fs_error
      end
    end

    Rails.logger.warn("#{n} Media works lack FileSets or have FileSets missing original_file")
  end

  desc 'Mass ingest data'
  task :mass_ingest => :environment do  
    MassIngestJob.perform_later({csv_path: File.expand_path("tmp/ingest/"), update: true, update_only_if_no_file: true})
  end

  desc 'Mass ingest data not in a job context'
  task :mass_ingest_no_job => :environment do  
    Ms1to2::Importer.new(File.expand_path("tmp/ingest/"), true, true).call
  end

  desc 'Set up MS dev team user accounts'
  task :create_users => :environment do
    emails = ['julia.m.winchester@gmail.com', 'jocelyn.triplett@duke.edu', 'simon.choy@duke.edu', 'douglasmb@gmail.com']
    admin = Role.where("name = 'admin'")[0] || Role.create(name: 'admin')

    emails.each do |email|
      if !User.find_by_user_key(email)
        u = User.new(attributes={email: email, password: 'testpass'})
        u.save!
      end
      admin.users << User.find_by_user_key(email)
    end

    admin.save
  end
end
