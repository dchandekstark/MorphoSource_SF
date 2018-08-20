# Generated via
#  `rails generate hyrax:work PhysicalObject`
class PhysicalObject < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = PhysicalObjectIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :vouchered, presence: { message: 'Missing value in vouchered? field. Does the object you are adding still physically exist?'}

  include Morphosource::PhysicalObjectMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
