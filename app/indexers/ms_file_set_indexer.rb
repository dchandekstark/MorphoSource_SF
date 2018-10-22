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
      solr_doc['file_type_extension_tesim'] = object.file_type_extension
      solr_doc['file_meta_info_group_length_tesim'] = object.file_meta_info_group_length
      solr_doc['file_meta_info_version_tesim'] = object.file_meta_info_version
      solr_doc['media_storage_sop_class_uid_tesim'] = object.media_storage_sop_class_uid
      solr_doc['media_storage_sop_instance_uid_tesim'] = object.media_storage_sop_instance_uid
      solr_doc['transfer_syntax_uid_tesim'] = object.transfer_syntax_uid
      solr_doc['implementation_class_uid_tesim'] = object.implementation_class_uid
      solr_doc['implementation_version_name_tesim'] = object.implementation_version_name
      solr_doc['specific_character_set_tesim'] = object.specific_character_set
      solr_doc['image_type_tesim'] = object.image_type
      solr_doc['sop_class_uid_tesim'] = object.sop_class_uid
      solr_doc['sop_instance_uid_tesim'] = object.sop_instance_uid
      solr_doc['study_date_tesim'] = object.study_date
      solr_doc['series_date_tesim'] = object.series_date
      solr_doc['content_date_tesim'] = object.content_date
      solr_doc['study_time_tesim'] = object.study_time
      solr_doc['series_time_tesim'] = object.series_time
      solr_doc['content_time_tesim'] = object.content_time
      solr_doc['accession_number_tesim'] = object.accession_number
      solr_doc['conversion_type_tesim'] = object.conversion_type
      solr_doc['study_description_tesim'] = object.study_description
      solr_doc['series_description_tesim'] = object.series_description
      solr_doc['study_instance_uid_tesim'] = object.study_instance_uid
      solr_doc['series_instance_uid_tesim'] = object.series_instance_uid
      solr_doc['instance_number_tesim'] = object.instance_number
      solr_doc['image_position_patient_tesim'] = object.image_position_patient
      solr_doc['image_orientation_patient_tesim'] = object.image_orientation_patient
      solr_doc['samples_per_pixel_tesim'] = object.samples_per_pixel
      solr_doc['photometric_interpretation_tesim'] = object.photometric_interpretation
      solr_doc['dcm_rows_tesim'] = object.dcm_rows
      solr_doc['dcm_columns_tesim'] = object.dcm_columns
      solr_doc['pixel_spacing_tesim'] = object.pixel_spacing
      solr_doc['bits_allocated_tesim'] = object.bits_allocated
      solr_doc['bits_stored_tesim'] = object.bits_stored
      solr_doc['high_bit_tesim'] = object.high_bit
      solr_doc['pixel_representation_tesim'] = object.pixel_representation
      solr_doc['window_center_tesim'] = object.window_center
      solr_doc['window_width_tesim'] = object.window_width
      solr_doc['rescale_intercept_tesim'] = object.rescale_intercept
      solr_doc['rescale_slope_tesim'] = object.rescale_slope
      solr_doc['window_center_and_width_explanation_tesim'] = object.window_center_and_width_explanation
      solr_doc['pixel_data_tesim'] = object.pixel_data
    end
  end
end
