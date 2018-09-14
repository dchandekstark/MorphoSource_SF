# Generated via
#  `rails generate hyrax:work PhysicalObject`
module Hyrax
  class PhysicalObjectPresenter < Hyrax::WorkShowPresenter
    delegate :bibliographic_citation, :physical_object_type, :catalog_number, :collection_code, :current_location, :institution, :numeric_time, :original_location, :periodic_time, :vouchered, :idigbio_recordset_id, :idigbio_uuid, :is_type_specimen, :occurrence_id, :sex, :cho_type, :material,  to: :solr_document
  end
end
