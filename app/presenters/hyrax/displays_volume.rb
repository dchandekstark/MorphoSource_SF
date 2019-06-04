# based on DisplaysMesh
require 'iiif_manifest'

module Hyrax
  # This gets mixed into MediaFileSetPresenter in order to create
  # a canvas on a IIIF manifest
  module DisplaysVolume
    extend ActiveSupport::Concern

    # @return [IIIFManifest::DisplayVolume] usable by the manifest builder.
    def display_volume
      return nil unless ::FileSet.exists?(id) && solr_document.volume? && current_ability.can?(:read, id)

      url = Hyrax::Engine.routes.url_helpers.download_path(id, file: 'aleph')
      format = 'application/json'
      type = 'PhysicalObject'

      IIIFManifest::DisplayVolume.new(url,
                                    format: format,
                                    type: type)
    end
  end
end
