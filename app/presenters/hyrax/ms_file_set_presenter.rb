module Hyrax
  class MsFileSetPresenter < Hyrax::FileSetPresenter

    def self.characterization_terms
      super + [
        :bits_per_sample, 
        :spacing_between_slices,
        :modality,
        :secondary_capture_device_manufacturer,
        :secondary_capture_device_software_vers,
        :file_type_extension,
        :image_type,
        :study_date,
        :series_date,
        :content_date,
        :study_time,
        :series_time,
        :content_time,
        :accession_number,
        :instance_number,
        :image_position_patient,
        :image_orientation_patient,
        :samples_per_pixel,
        :photometric_interpretation,
        :dcm_rows,
        :dcm_columns,
        :pixel_spacing,
        :bits_allocated,
        :bits_stored,
        :high_bit,
        :pixel_representation,
        :window_center,
        :window_width,
        :rescale_intercept,
        :rescale_slope,
        :window_center_and_width_explanation
      ]
    end

    # for images
    delegate :bits_per_sample, to: :solr_document
      
    # for dicom  
    delegate  :spacing_between_slices, 
              :modality,
              :secondary_capture_device_manufacturer,
              :secondary_capture_device_software_vers,
              :file_type_extension,
              :image_type,
              :study_date,
              :series_date,
              :content_date,
              :study_time,
              :series_time,
              :content_time,
              :accession_number,
              :instance_number,
              :image_position_patient,
              :image_orientation_patient,
              :samples_per_pixel,
              :photometric_interpretation,
              :dcm_rows,
              :dcm_columns,
              :pixel_spacing,
              :bits_allocated,
              :bits_stored,
              :high_bit,
              :pixel_representation,
              :window_center,
              :window_width,
              :rescale_intercept,
              :rescale_slope,
              :window_center_and_width_explanation,
              to: :solr_document
  end
end