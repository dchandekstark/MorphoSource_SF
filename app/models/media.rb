class Media < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator
  after_save :add_id_to_title

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

    file_sets.each do |file|
      if file.embargo&.active?
        file_visibilities << Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
      elsif file.lease&.active?
        file_visibilities << Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE
      else
        file_visibilities << file.visibility
      end
    end
    # order unique visibilities in the order that they appear on the work form.
    all_visibilities & file_visibilities
  end

  def restricted?
    if fileset_accessibility
      fileset_accessibility.first == "restricted_download"
    else
      false
    end
  end

  def open?
    accessibility = fileset_accessibility.first
    unless accessibility.nil?
      accessibility == "open"
    # TODO: remove after migrated media have fileset_accessibility
    else
      true
    end
  end

  def publication_status
    fileset_accessibility = self.fileset_accessibility.first

    case
    when fileset_accessibility == "open"
      "open"
    when fileset_accessibility == "restricted_download"
      "restricted"
    when fileset_accessibility == "preview_only"
      "preview"
    when fileset_accessibility == "hidden"
      "hidden"
    when fileset_accessibility == "private"
      "private"
    when self.embargo && self.embargo.active?
      "embargo"
    when self.lease && self.lease.active?
      "lease"
      #TODO: remove after migrated media have fileset_accessibility values
    when fileset_accessibility == nil
      "open"
    end
  end

  private
    def add_id_to_title
      unless self.title && self.id && self.title.first.to_s.start_with?("M#{self.id.to_s}: ")
        self.title.set("M#{self.id.to_s}: #{self.title.first.to_s}")
      end
    end
end
