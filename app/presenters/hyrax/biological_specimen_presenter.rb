# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  class BiologicalSpecimenPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :bibliographic_citation, :catalog_number,  :collection_code, :numeric_time, :original_location, :periodic_time, :vouchered, :idigbio_recordset_id, :idigbio_uuid, :is_type_specimen, :occurrence_id, :sex, :geographic_coordinates, :member_ids, to: :solr_document

    delegate :taxonomies, :canonical_taxonomy_object, :trusted_taxonomies, :user_taxonomies, to: :work

    def canonical_taxonomy_label
      if canonical_taxonomy_object.present?
        if canonical_taxonomy_object.trusted == ["Yes"]
          return "Institutional / MorphoSource Inferred"
        end
      end
      "Institutional"
    end

    def canonical_taxonomy_presenter
      Hyrax::TaxonomyPresenter.new(canonical_taxonomy_solr, current_ability, request)
    end

    def canonical_taxonomy_solr
      Taxonomy.find(work.canonical_taxonomy.first).to_solr
    end

  end
end
