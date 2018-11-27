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

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::MediaPresenter

    # Overriding WorksControllerBehavior to add file format validation
    # Could not do this as an ActiveModel validation because new file uploads are not added until after create
    def create
     if valid_file_formats && actor.create(actor_environment)
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
      if valid_file_formats && actor.update(actor_environment)
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
      def valid_file_formats
        invalid_files = []
        media_type = attributes_for_actor["media_type"].first

        attributes_for_actor["uploaded_files"].each do |file_id|
          file_name = Hyrax::UploadedFile.find(file_id)["file"]

          invalid_files << file_name unless Morphosource.send(Morphosource::MEDIA_FORMATS[media_type]).include? File.extname(file_name)
        end

        return true if invalid_files.length == 0

        curation_concern.errors.add(:base, "Invalid files: #{invalid_files.uniq.join(', ')} for Media Type: #{media_type}.")
        false
      end
  end
end
