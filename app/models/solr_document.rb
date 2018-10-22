# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension( Hydra::ContentNegotiation )

  # MorphoSource customizations

  # Fileset methods
  def file_ext
    File.extname(label)
  end

  def mesh? # TODO: Needs to be adjusted to use mime types when FITS issue is dealt with
    accepted_formats = [".ply", ".stl", ".obj", ".gltf"]
    accepted_formats.include? file_ext
  end

  def mesh_mime_type # TODO: Temporary, should not exist forever
    mesh_mime_types = { ".ply" => "application/ply", 
                        ".stl" => "application/sla", 
                        ".obj" => "text/plain", 
                        ".gltf" => "model/gltf+json" }
    mesh_mime_types[file_ext]
  end

  # Add custom metadata fields to show view

  # Media Fields
  def agreement_uri
    self[Solrizer.solr_name('agreement_uri', :stored_searchable)]
  end

  def cite_as
    self[Solrizer.solr_name('cite_as', :stored_searchable)]
  end

  def funding
    self[Solrizer.solr_name('funding', :stored_searchable)]
  end

  def map_type
    self[Solrizer.solr_name('map_type', :stored_searchable)]
  end

  def media_type
    self[Solrizer.solr_name('media_type', :stored_searchable)]
  end

  def modality
    self[Solrizer.solr_name('modality', :stored_searchable)]
  end

  def orientation
    self[Solrizer.solr_name('orientation', :stored_searchable)]
  end

  def part
    self[Solrizer.solr_name('part', :stored_searchable)]
  end

  def rights_holder
    self[Solrizer.solr_name('rights_holder', :stored_searchable)]
  end

  def scale_bar
    self[Solrizer.solr_name('scale_bar', :stored_searchable)]
  end

  def side
    self[Solrizer.solr_name('side', :stored_searchable)]
  end

  def unit
    self[Solrizer.solr_name('unit', :stored_searchable)]
  end

  def x_spacing
    self[Solrizer.solr_name('x_spacing', :stored_searchable)]
  end

  def y_spacing
    self[Solrizer.solr_name('y_spacing', :stored_searchable)]
  end

  def z_spacing
    self[Solrizer.solr_name('z_spacing', :stored_searchable)]
  end

  # Physical Object Fields
  def bibliographic_citation
    self[Solrizer.solr_name('bibliographic_citation', :stored_searchable)]
  end

  def catalog_number
    self[Solrizer.solr_name('catalog_number', :stored_searchable)]
  end

  def collection_code
    self[Solrizer.solr_name('collection_code', :stored_searchable)]
  end

  def current_location
    self[Solrizer.solr_name('current_location', :stored_searchable)]
  end

  def geographic_coordinates
    if (latitude && longitude)
      "Latitude: " + latitude[0] + ", Longitude: " + longitude[0]
    elsif latitude
      "Latitude: " + latitude[0]
    elsif longitude
      "Longitude: " + longitude[0]
    end
  end

  def institution
    self[Solrizer.solr_name('institution', :stored_searchable)]
  end

  def latitude
    self[Solrizer.solr_name('latitude', :stored_searchable)]
  end

  def longitude
    self[Solrizer.solr_name('longitude', :stored_searchable)]
  end

  def numeric_time
    self[Solrizer.solr_name('numeric_time', :stored_searchable)]
  end

  def original_location
    self[Solrizer.solr_name('original_location', :stored_searchable)]
  end

  def periodic_time
    self[Solrizer.solr_name('periodic_time', :stored_searchable)]
  end

  def physical_object_type
    self[Solrizer.solr_name('physical_object_type', :stored_searchable)]
  end

  def vouchered
    self[Solrizer.solr_name('vouchered', :stored_searchable)]
  end

  # Biological Specimens only
  def idigbio_recordset_id
    self[Solrizer.solr_name('idigbio_recordset_id', :stored_searchable)]
  end

  def idigbio_uuid
    self[Solrizer.solr_name('idigbio_uuid', :stored_searchable)]
  end

  def is_type_specimen
    self[Solrizer.solr_name('is_type_specimen', :stored_searchable)]
  end

  def occurrence_id
    self[Solrizer.solr_name('occurrence_id', :stored_searchable)]
  end

  def sex
    self[Solrizer.solr_name('sex', :stored_searchable)]
  end

  # CHOs only
  def cho_type
    self[Solrizer.solr_name('cho_type', :stored_searchable)]
  end

  def material
    self[Solrizer.solr_name('material', :stored_searchable)]
  end
    

  # images
  def bits_per_sample
    self[Solrizer.solr_name('bits_per_sample', :stored_searchable)]
  end

  # dicom
  def spacing_between_slices
    self[Solrizer.solr_name('spacing_between_slices', :stored_searchable)]
  end
    
  def modality
    self[Solrizer.solr_name('modality', :stored_searchable)]
  end
    
  def secondary_capture_device_manufacturer
    self[Solrizer.solr_name('secondary_capture_device_manufacturer', :stored_searchable)]
  end
    
  def secondary_capture_device_software_vers
    self[Solrizer.solr_name('secondary_capture_device_software_vers', :stored_searchable)]
  end
    
  def file_type_extension
    self[Solrizer.solr_name('file_type_extension', :stored_searchable)]
  end

  def file_meta_info_group_length
    self[Solrizer.solr_name('file_meta_info_group_length', :stored_searchable)]
  end

  def file_meta_info_version
    self[Solrizer.solr_name('file_meta_info_version', :stored_searchable)]
  end

  def media_storage_sop_class_uid
    self[Solrizer.solr_name('media_storage_sop_class_uid', :stored_searchable)]
  end

  def media_storage_sop_instance_uid
    self[Solrizer.solr_name('media_storage_sop_instance_uid', :stored_searchable)]
  end

  def transfer_syntax_uid
    self[Solrizer.solr_name('transfer_syntax_uid', :stored_searchable)]
  end

  def implementation_class_uid
    self[Solrizer.solr_name('implementation_class_uid', :stored_searchable)]
  end

  def implementation_version_name
    self[Solrizer.solr_name('implementation_version_name', :stored_searchable)]
  end

  def specific_character_set
    self[Solrizer.solr_name('specific_character_set', :stored_searchable)]
  end

  def image_type
    self[Solrizer.solr_name('image_type', :stored_searchable)]
  end

  def sop_class_uid
    self[Solrizer.solr_name('sop_class_uid', :stored_searchable)]
  end

  def sop_instance_uid
    self[Solrizer.solr_name('sop_instance_uid', :stored_searchable)]
  end

  def study_date
    self[Solrizer.solr_name('study_date', :stored_searchable)]
  end

  def series_date
    self[Solrizer.solr_name('series_date', :stored_searchable)]
  end

  def content_date
    self[Solrizer.solr_name('content_date', :stored_searchable)]
  end

  def study_time
    self[Solrizer.solr_name('study_time', :stored_searchable)]
  end

  def series_time
    self[Solrizer.solr_name('series_time', :stored_searchable)]
  end

  def content_time
    self[Solrizer.solr_name('content_time', :stored_searchable)]
  end

  def accession_number
    self[Solrizer.solr_name('accession_number', :stored_searchable)]
  end

  def conversion_type
    self[Solrizer.solr_name('conversion_type', :stored_searchable)]
  end

  def referring_physician_name
    self[Solrizer.solr_name('referring_physician_name', :stored_searchable)]
  end

  def study_description
    self[Solrizer.solr_name('study_description', :stored_searchable)]
  end

  def series_description
    self[Solrizer.solr_name('series_description', :stored_searchable)]
  end

  def patient_name
    self[Solrizer.solr_name('patient_name', :stored_searchable)]
  end

  def patient_id
    self[Solrizer.solr_name('patient_id', :stored_searchable)]
  end

  def patient_birth_date
    self[Solrizer.solr_name('patient_birth_date', :stored_searchable)]
  end

  def study_instance_uid
    self[Solrizer.solr_name('study_instance_uid', :stored_searchable)]
  end

  def series_instance_uid
    self[Solrizer.solr_name('series_instance_uid', :stored_searchable)]
  end

  def instance_number
    self[Solrizer.solr_name('instance_number', :stored_searchable)]
  end

  def image_position_patient
    self[Solrizer.solr_name('image_position_patient', :stored_searchable)]
  end

  def image_orientation_patient
    self[Solrizer.solr_name('image_orientation_patient', :stored_searchable)]
  end

  def samples_per_pixel
    self[Solrizer.solr_name('samples_per_pixel', :stored_searchable)]
  end

  def photometric_interpretation
    self[Solrizer.solr_name('photometric_interpretation', :stored_searchable)]
  end

  def dcm_rows
    self[Solrizer.solr_name('dcm_rows', :stored_searchable)]
  end

  def dcm_columns
    self[Solrizer.solr_name('dcm_columns', :stored_searchable)]
  end

  def pixel_spacing
    self[Solrizer.solr_name('pixel_spacing', :stored_searchable)]
  end

  def bits_allocated
    self[Solrizer.solr_name('bits_allocated', :stored_searchable)]
  end

  def bits_stored
    self[Solrizer.solr_name('bits_stored', :stored_searchable)]
  end

  def high_bit
    self[Solrizer.solr_name('high_bit', :stored_searchable)]
  end

  def pixel_representation
    self[Solrizer.solr_name('pixel_representation', :stored_searchable)]
  end

  def window_center
    self[Solrizer.solr_name('window_center', :stored_searchable)]
  end

  def window_width
    self[Solrizer.solr_name('window_width', :stored_searchable)]
  end

  def rescale_intercept
    self[Solrizer.solr_name('rescale_intercept', :stored_searchable)]
  end

  def rescale_slope
    self[Solrizer.solr_name('rescale_slope', :stored_searchable)]
  end

  def window_center_and_width_explanation
    self[Solrizer.solr_name('window_center_and_width_explanation', :stored_searchable)]
  end

  def pixel_data
    self[Solrizer.solr_name('pixel_data', :stored_searchable)]
  end

end
