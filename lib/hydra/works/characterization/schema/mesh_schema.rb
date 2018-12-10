module Hydra::Works::Characterization
  class MeshSchema < ActiveTriples::Schema
    property :point_count, predicate: RDF::URI('http://purl.org/healthcarevocab/v1/foo')
    property :face_count, predicate: RDF::URI('http://purl.org/healthcarevocab/v1/bar')
  end
end
