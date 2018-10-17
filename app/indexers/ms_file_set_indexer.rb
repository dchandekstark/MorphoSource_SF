# override `generate_solr_document` by calling super and indexing the other fields you care about.
class MsFileSetIndexer < Hyrax::FileSetIndexer

    def generate_solr_document
      super.tap do |solr_doc|
          # images
          solr_doc['bits_per_sample_tesim'] = object.bits_per_sample
          # dicom
          solr_doc['spacing_between_slices_tesim'] = object.spacing_between_slices
          solr_doc['modality_tesim'] = object.modality
          solr_doc['secondary_capture_device_manufacturer_tesim'] = object.secondary_capture_device_manufacturer
          solr_doc['secondary_capture_device_software_vers_tesim'] = object.secondary_capture_device_software_vers

      end
    end

end
