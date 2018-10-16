module Hydra::Works::Characterization
  class DicomSchema < ActiveTriples::Schema
#    property :spacing_between_slices, predicate: RDF::Vocab::EXIF.spacingBetweenSlices
      property :spacing_between_slices, predicate: RDF::URI('https://www.morphosource.org/terms/spacingBetweenSlices')
  end
end
