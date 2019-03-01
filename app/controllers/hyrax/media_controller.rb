# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  # Generated controller for Media
  class MediaController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::Media

    include ActionController::Streaming
    include Zipline
    require 'open-uri'

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::MediaPresenter

    before_action :set_fileset_visibility, only: [:create, :update]
    skip_load_and_authorize_resource only: [:zip]

    # GET /concern/media/zip?ids[]=filesetid1&ids[]=filesetid2
    def zip
      if params[:ids] && params[:ids].is_a?(Array) && params[:ids].any?
        params[:ids].uniq!
        params[:ids].each{|i| authorize! :read, i} unless (Rails.env == 'test')
        files = ::Media.where(id: params[:ids]).map{|m| m.file_sets}.flatten.map do |f|
          authorize!(:read, f.id) unless (Rails.env == 'test')
          m = f.parent
          # Unzipped filename will be e.g. "Structured Light-2514nk481/bun_zipper_res2-nc580m649.ply"
          output_dirname = "#{m.title.join('-').tr('[]','')}-#{m.id}"
          output_filename = File.basename(f.label, File.extname(f.label)) + "-#{f.id}" + File.extname(f.label)
          [f.original_file.uri.to_s, "#{output_dirname}/#{output_filename}", modification_time: f.date_modified]
        end
        Rails.logger.debug("Files for zip: #{files.inspect}")
        file_mappings = files.lazy.map{|url,path,options| [open(url), path, options]}
        zipline(file_mappings, "morphosource-#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.zip")
      end
    end

    # Overriding WorksControllerBehavior to add file format validation
    # Could not do this as an ActiveModel validation because new file uploads are not added until after create
    def create
     if file_formats_valid? && actor.create(actor_environment)
       after_create_response
     else
       respond_to do |wants|
         wants.html do
           build_form
           render 'new', status: :unprocessable_entity
         end
         wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
       end
     end
   end

   def update
      if file_formats_valid? && actor.update(actor_environment)
        after_update_response
      else
        respond_to do |wants|
          wants.html do
            build_form
            render 'edit', status: :unprocessable_entity
          end
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
        end
      end
    end

    private

      def manifest_builder
        ::IIIFManifest::V3::ManifestFactory.new(presenter)
      end

      # Checks that uploaded files are the correct format for selected media type.
      def validate_file_formats
        files = []
        invalid_files = []
        media_type = attributes_for_actor["media_type"].first

        # New uploads
        attributes_for_actor["uploaded_files"].each do |file_id|
          files << Hyrax::UploadedFile.find(file_id)["file"]
        end

        # Previous uploads
        self.curation_concern.file_sets.each do |file_set|
          files << file_set.original_file.original_name
        end

        files.each do |file|
          invalid_files << file unless Morphosource::MEDIA_FORMATS[media_type][:extensions].include? File.extname(file)
        end

        if invalid_files.length != 0
          curation_concern.errors.add(:base, "Invalid files: #{invalid_files.uniq.join(', ')} for Media Type: #{Morphosource::MEDIA_FORMATS[media_type][:label]}.")
        end
      end

      def file_formats_valid?
        validate_file_formats
        curation_concern.errors.empty? ? true : false
      end

      def set_fileset_visibility
        if params["media"]["fileset_visibility"] == "restricted"
          curation_concern.fileset_visibility = ["restricted"]
        else
          curation_concern.fileset_visibility = [""]
        end
      end
  end
end
