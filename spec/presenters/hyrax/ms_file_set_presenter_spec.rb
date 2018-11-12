require 'iiif_manifest'
require 'rails_helper'

RSpec.describe Hyrax::MsFileSetPresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:ability) { double "Ability" }
  let(:presenter) { described_class.new(solr_document, ability, request) }
  let(:attributes) { file.to_solr }
  let(:user) { double(user_key: 'sarah') }

  let(:request) { double(base_url: 'http://test.host') }
  let(:id) { '999' }
  let(:read_permission) { true }  
  
  describe 'Dicom characterization' do
    let(:file_set) { FactoryBot.create(:file_set) }
    let(:file_path_string) {fixture_path + '/CMB06020_R-m1_011.dcm'}
    let(:dcm_file) { File.open(file_path_string) }

    before do
      Hydra::Works::AddFileToFileSet.call(file_set, dcm_file, :original_file)
      # perform the characterization job ( app/jobs/characterize_job.rb )
      CharacterizeJob.perform_now(file_set, file_set.original_file.id, file_path_string)
    end

    # find the solr doc, then verify the metadata
    subject { SolrDocument.find(file_set.id) }

    it "has dicom attributes in the metadata" do
      expect(subject[:mime_type_ssi]).to eq("application/dicom")
      expect(subject[:spacing_between_slices_tesim].first).to eq("0.0100088")
      expect(subject[:modality_tesim].first).to eq("OT")
      expect(subject[:secondary_capture_device_manufacturer_tesim].first).to eq("FEI")
      expect(subject[:secondary_capture_device_software_vers_tesim].first).to eq("Avizo")
    end
      
  end
    
end