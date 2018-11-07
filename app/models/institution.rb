class Institution < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator

  self.indexer = InstitutionIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [Device, BiologicalSpecimen, CulturalHeritageObject, Attachment]

  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::InstitutionMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
