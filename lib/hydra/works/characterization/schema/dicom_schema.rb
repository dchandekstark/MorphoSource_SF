module Hydra::Works::Characterization
  class DicomSchema < ActiveTriples::Schema
#    property :spacing_between_slices, predicate: RDF::Vocab::EXIF.spacingBetweenSlices
    property :spacing_between_slices, predicate: RDF::URI('https://www.morphosource.org/terms/spacingBetweenSlices')
    property :modality, predicate: RDF::URI('https://www.morphosource.org/terms/modality')
    property :secondary_capture_device_manufacturer, predicate: RDF::URI('https://www.morphosource.org/terms/secondaryCaptureDeviceManufacturer')
    property :secondary_capture_device_software_vers, predicate: RDF::URI('https://www.morphosource.org/terms/secondaryCaptureDeviceSoftwareVers')
  end
end
