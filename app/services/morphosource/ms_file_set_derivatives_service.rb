module Morphosource
  # Responsible for creating and cleaning up the derivatives of a file_set with MS-specific methods
  class MsFileSetDerivativesService < Hyrax::FileSetDerivativesService
    def create_derivatives(filename)
      case mime_type
      when *file_set.class.pdf_mime_types             then create_pdf_derivatives(filename)
      when *file_set.class.office_document_mime_types then create_office_document_derivatives(filename)
      when *file_set.class.audio_mime_types           then create_audio_derivatives(filename)
      when *file_set.class.video_mime_types           then create_video_derivatives(filename)
      when *file_set.class.image_mime_types           then create_image_derivatives(filename)
      when *file_set.class.mesh_mime_types            then create_mesh_derivatives(filename)
      when *file_set.class.archive_mime_types         then create_archive_derivatives(filename)
      end
    end

    private

      def supported_mime_types
        file_set.class.pdf_mime_types +
          file_set.class.office_document_mime_types +
          file_set.class.audio_mime_types +
          file_set.class.video_mime_types +
          file_set.class.image_mime_types +
          file_set.class.mesh_mime_types + 
          file_set.class.archive_mime_types
      end

      def create_mesh_derivatives(filename)
        Morphosource::Derivatives::MeshDerivatives.create(filename,
                                                          outputs: [{ label: :glb,
                                                                      format: 'glb',
                                                                      unit: file_set.member_of.first.unit.first,
                                                                      url: derivative_url('glb')}])
      end

      def create_archive_derivatives(filename)
        if file_set.member_of.first.media_type.first == 'CTImageSeries'
          Morphosource::Derivatives::CTImageSeriesDerivatives.create(filename,
                                                                     outputs: [{ label: :aleph,
                                                                                 file_set_id: file_set.id,
                                                                                 url: derivative_url('aleph')}])
        elsif file_set.member_of.first.media_type.first == 'Mesh'
           Morphosource::Derivatives::MeshDerivatives.create(filename,
                                                             outputs: [{ label: :glb,
                                                                         format: 'glb',
                                                                         unit: file_set.member_of.first.unit.first,
                                                                         url: derivative_url('glb')}])
        end
      end
  end
end
