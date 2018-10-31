# Generated via
#  `rails generate hyrax:work ImagingEvent`
module Hyrax
  class ImagingEventPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    class_attribute :work_presenter_class
    self.work_presenter_class = ImagingEventPresenter

    delegate  :description,
            :creator,
            :title,
            :software,
            :ie_modality,
            # X-ray CT metadata
            :exposure_time,
            :flux_normalization,
            :geometric_calibration,
            :shading_correction,
            :filter,
            :frame_averaging,
            :projections,
            :voltage,
            :power,
            :amperage,
            :surrounding_material,
            :xray_tube_type,
            :target_type,
            :detector_type,
            :detector_configuration,
            :source_object_distance,
            :source_detector_distance,
            :target_material,
            :rotation_number,
            :phase_contrast,
            :optical_magnification,
            # Photogrammetry properties
            :focal_length_type,
            :background_removal,
            # Photogrammetry properties and Photography properties
            :lens_make,
            :lens_model,
            :light_source,
        to: :solr_document
  end
end
