class Submission
  include ActiveModel::Model

  attr_accessor :biospec_id,
                :biospec_or_cho,
                :biospec_search_catalog_number,
                :biospec_search_collection_code,
                :biospec_search_institution_code,
                :biospec_search_occurrence_id,
                :device_id,
                :imaging_event_id,
                :institution_id,
                :media_id,
                :processing_event_id,
                :raw_or_derived_media,
                :immediate_parents_count,
                :parent_media_type,
                :parent_media_id,

  MEDIA_DERIVED = 'Derived'
  MEDIA_RAW = 'Raw'
  PHYSICAL_OBJECT_BIOSPEC = { code: 'biospec',
                              klass: BiologicalSpecimen,
                              label: BiologicalSpecimen.human_readable_type }
  PHYSICAL_OBJECT_CHO = { code: 'cho',
                          klass: CulturalHeritageObject,
                          label: CulturalHeritageObject.human_readable_type }

  PARENT_MEDIA_IN_MORPHOSOURCE = 'Parent media is in MorphoSource'
  PARENT_MEDIA_NOT_AVAILABLE = 'Parent media is unavailable to me, but I have metadata'
  PARENT_MEDIA_TO_BE_UPLOADED = 'I have parent media and can upload it to MorphoSource'

end
