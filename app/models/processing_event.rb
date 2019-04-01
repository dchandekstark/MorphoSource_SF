class ProcessingEvent < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator
  after_create :add_id_to_title

  self.indexer = ProcessingEventIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [Media, Attachment]

  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::ProcessingEventMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  private
    def add_id_to_title
      self.title.set("PE#{self.id.to_s}: #{self.title.first.to_s}")
      self.save!
    end
end
