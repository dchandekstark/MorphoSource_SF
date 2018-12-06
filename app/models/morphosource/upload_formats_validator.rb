module Morphosource
  # validates that previously uploaded files are the correct extension based on the media type selected by the user.
  # Will not work for new file uploads, because the record is created before files are added to it. New file validation done by the media_controller.
  class UploadFormatsValidator < ActiveModel::Validator

    def validate(record)
      invalid_files = []
      media_type = record.media_type[0]

      record.file_sets.each do |file_set|
        invalid_files << file_set unless Morphosource.send(Morphosource::MEDIA_FORMATS[media_type]).include? file_set.file_extension
      end

      return if invalid_files.empty?

      invalid_file_names = invalid_files.map{|f| f.original_file.original_name}.uniq.join(', ')
      invalid_file_extensions = invalid_files.map{|f| f.file_extension}.uniq.join(', ')

      record.errors.add(:base, "Invalid files: #{invalid_file_names} for Media Type: #{media_type}.")
    end
  end
end
