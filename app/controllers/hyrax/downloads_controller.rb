require_dependency Hyrax::Engine.config.root.join('app','controllers','hyrax','downloads_controller.rb').to_s
class Hyrax::DownloadsController
  # Renders derivatives only. Original downloads are disabled.
  def show
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
end
