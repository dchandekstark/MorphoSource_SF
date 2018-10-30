require 'hydra/works/characterization/schema/image_ext_schema.rb'
require 'hydra/works/characterization/schema/dicom_schema.rb'
require 'hyrax/search_state' # this is needed for overriding FileSetPresenter with MsFileSetPresenter

ActiveFedora::WithMetadata::DefaultMetadataClassFactory.file_metadata_schemas +=
[ 
  Hydra::Works::Characterization::ImageExtSchema,
  Hydra::Works::Characterization::DicomSchema
]

Hyrax::FileSetsController.show_presenter = Hyrax::MsFileSetPresenter
