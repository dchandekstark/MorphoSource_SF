class MassIngestJob < ApplicationJob

  queue_as Hyrax.config.ingest_queue_name

  def perform(args)
  	Hyrax.config.whitelisted_ingest_dirs = [args[:ingest_path]]
    Ms1to2::Importer.new(args[:csv_path]).call
  end

end
