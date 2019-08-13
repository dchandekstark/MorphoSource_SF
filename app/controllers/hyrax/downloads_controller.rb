require_dependency Hyrax::Engine.config.root.join('app','controllers','hyrax','downloads_controller.rb').to_s
class Hyrax::DownloadsController
  # Renders derivatives only. Original downloads are disabled.
  def show
    Rails.logger.info("DownloadsController#show")
    Rails.logger.info("DownloadsController file: #{file.inspect}")
    case file
    when ActiveFedora::File
      # For original files that are stored in fedora
      unauthorized_image = Rails.root.join("app", "assets", "images", "unauthorized.png")
      send_file unauthorized_image, status: :unauthorized
    when String
      # For derivatives stored on the local file system
      send_local_content
    else
      raise ActiveFedora::ObjectNotFoundError
    end
  end

  private
    # Override authorize_download! to use the :read permission instead of the :download permission
    def authorize_download!
      authorize! :read, params[asset_param_key]
    rescue CanCan::AccessDenied
      unauthorized_image = Rails.root.join("app", "assets", "images", "unauthorized.png")
      send_file unauthorized_image, status: :unauthorized
    end

    def file
      @file ||= load_file
    end

    def load_file
      file_reference = params[:file]
      Rails.logger.info("DownloadsController#load_file: #{file_reference.inspect}")
      Rails.logger.info("DownloadsController asset_param_key: #{params[asset_param_key].inspect}")
      return default_file unless file_reference
      if file_reference.include? 'dcm'
        file_reference.slice!('dcm')
        file_path = Morphosource::DerivativePath.derivative_path_for_reference(params[asset_param_key], 'dcm', file_reference.to_i)
      else
        file_path = Morphosource::DerivativePath.derivative_path_for_reference(params[asset_param_key], file_reference)
      end

      File.exist?(file_path) ? file_path : nil
    end
end
