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

  desc 'Mass ingest data'
  task :mass_ingest => :environment do
    Ms1to2::Importer.new(File.expand_path("tmp/ingest/")).call 
  end

  desc 'Set up MS dev team user accounts'
  task :create_users => :environment do
    emails = ['julia.m.winchester@gmail.com', 'jocelyn.triplett@duke.edu', 'simon.choy@duke.edu', 'douglasmb@gmail.com']
    admin = Role.where("name = 'admin'")[0] || Role.create(name: 'admin')

    emails.each do |email|
      if !User.find_by_user_key(email)
        u = User.new(attributes={email: email, password: 'testpass'})
        u.save!
        admin.users << User.find_by_user_key(email)
      end
    end

    admin.save
  end
end
