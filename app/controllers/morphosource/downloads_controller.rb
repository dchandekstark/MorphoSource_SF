module Morphosource
  class DownloadsController < Hyrax::DownloadsController
    private

      def mime_type_for(file)
        case File.extname(file)
        when '.glb'
          'model/gltf+json'
        else
          MIME::Types.type_for(File.extname(file)).first.content_type
        end
      end
  end
end
