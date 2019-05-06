module Hyrax
  class CustomThumbnailsController < ApplicationController
    # POST /works/:id/custom_thumbnail
    def create
      Rails.logger.info("CustomThumbnailsController#create params: #{params.inspect}")
      # view uses: f.file_field :image
      params.require([:id,:image])
      authorize!(:edit, params[:id])
      if Morphosource::MEDIA_FORMATS['Image'][:extensions].include? File.extname(params[:image].original_filename)
        thumbnail_path = Hyrax::DerivativePath.derivative_path_for_reference(params[:id],'thumbnail')
        original_thumbnail_path = Hyrax::DerivativePath.derivative_path_for_reference(params[:id],'original_thumbnail')
        Rails.logger.info("CustomThumbnailsController#create thumbnail_path: #{thumbnail_path}")
        Rails.logger.info("CustomThumbnailsController#create original_thumbnail_path: #{original_thumbnail_path}")
        # Move an existing original 'thumbnail' to 'original_thumbnail',
        # but don't overwrite an 'original_thumbnail'
        if File.exist?(thumbnail_path)
          if !File.exist?(original_thumbnail_path)
            FileUtils.mv thumbnail_path, original_thumbnail_path
          else
            FileUtils.rm thumbnail_path
          end
        end
        FileUtils.mkdir_p(File.dirname(thumbnail_path))
        File.open(thumbnail_path, 'wb') do |file|
          file.write(params[:image].read)
        end
      end
    end

    # DELETE /works/:id/custom_thumbnail
    def destroy
      Rails.logger.info("CustomThumbnailsController#destroy params: #{params.inspect}")
      params.require(:id)
      authorize!(:edit, params[:id])
      thumbnail_path = Hyrax::DerivativePath.derivative_path_for_reference(params[:id],'thumbnail')
      original_thumbnail_path = Hyrax::DerivativePath.derivative_path_for_reference(params[:id],'original_thumbnail')
      Rails.logger.info("CustomThumbnailsController#destroy thumbnail_path: #{thumbnail_path}")
      Rails.logger.info("CustomThumbnailsController#destroy original_thumbnail_path: #{original_thumbnail_path}")
      if File.exist?(thumbnail_path)
        FileUtils.rm thumbnail_path
      end
      if File.exist?(original_thumbnail_path)
        FileUtils.mv original_thumbnail_path, thumbnail_path
      end
    end
  end
end
