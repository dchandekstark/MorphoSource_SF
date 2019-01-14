class Media < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator

  self.work_requires_files = true

  self.indexer = MediaIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [ProcessingEvent, Attachment]

  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::MediaMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  # array of all visibilities that apply to the file sets of a Media work
  # used to populate File Visibility column in dashboard works list
  def file_set_visibilities

    all_visibilities = [
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED,
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO,
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE,
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE ]

    file_visibilities = []

    file_set_ids.each do |id|
      file = FileSet.find(id)
      if file.embargo_id.present?
        file_visibilities << "embargo"
      elsif file.lease_id.present?
        file_visibilities << "lease"
      else
        file_visibilities << file.visibility
      end
    end
    # order unique visibilities in the order that they appear on the work form.
    all_visibilities & file_visibilities
  end
end
