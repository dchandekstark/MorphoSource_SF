class MassIngestJob < ApplicationJob

  queue_as Hyrax.config.ingest_queue_name

  def perform(args)
    Ms1to2::Importer.new(args[:csv_path]).call
  end

end
