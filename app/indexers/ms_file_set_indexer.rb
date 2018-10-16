# override `generate_solr_document` by calling super and indexing the other fields you care about.
class MsFileSetIndexer < Hyrax::FileSetIndexer

    def generate_solr_document
      super.tap do |solr_doc|
          solr_doc['bits_per_sample_tesim'] = object.bits_per_sample
          solr_doc['spacing_between_slices_tesim'] = object.spacing_between_slices

      end
    end

end
