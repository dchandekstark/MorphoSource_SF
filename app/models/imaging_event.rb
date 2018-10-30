class ImagingEvent < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  self.work_requires_files = false
  self.indexer = ImagingEventIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::ImagingEventMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata


#  property :ms_creator, predicate: ::RDF::Vocab::DC11.creator, multiple: false do |index|
 #   index.as :stored_searchable
#  end

 # property :ms_description, predicate: ::RDF::Vocab::DC11.description, multiple: false do |index|
#    index.as :stored_searchable
 # end

end
