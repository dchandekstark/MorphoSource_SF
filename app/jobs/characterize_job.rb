class CharacterizeJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # Characterizes the file at 'filepath' if available, otherwise, pulls a copy from the repository
  # and runs characterization on that file.
  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  def perform(file_set, file_id, filepath = nil)
    raise "#{file_set.class.characterization_proxy} was not found for FileSet #{file_set.id}" unless file_set.characterization_proxy?
    filepath = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id) unless filepath && File.exist?(filepath)

    # Run FITS , then blender (if it is a mesh file type).  
    # For mesh files:
    # - we want blender to overwrite the mime type output from FITS
    # - we still want to run FITS to get basic file info (e.g. checksum) 
    Hydra::Works::CharacterizationService.run(file_set.characterization_proxy, filepath)
    Rails.logger.debug "Ran FITS characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"

    ext = File.extname(filepath)
    if (ext =~ /\.(gltf|obj|ply|stl|wrl|x3d)$/)
      blender_options = {
        "parser_class" => Hydra::Works::Characterization::BlenderDocument, 
        "tool_class" => :blender
      }
      Hydra::Works::CharacterizationService.run(file_set.characterization_proxy, filepath, blender_options)
      Rails.logger.debug "Ran Blender characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
    end
    file_set.characterization_proxy.save!
    file_set.update_index
    file_set.parent&.in_collections&.each(&:update_index)
    CreateDerivativesJob.perform_later(file_set, file_id, filepath)
  end
end