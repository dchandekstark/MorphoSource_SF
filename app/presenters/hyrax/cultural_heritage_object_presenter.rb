# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
module Hyrax
  class CulturalHeritageObjectPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods
    class_attribute :work_presenter_class

    self.work_presenter_class = CulturalHeritageObjectPresenter


    delegate :bibliographic_citation, :catalog_number, :collection_code, :institution, :numeric_time,
             :original_location, :periodic_time, :vouchered, :cho_type, :material, :short_title,
             :geographic_coordinates, to: :solr_document
  end
end
