# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'
require 'iiif_manifest'
include ActionDispatch::TestProcess

RSpec.describe Hyrax::MediaController do
  let(:work_solr_document) do
    SolrDocument.new(id: '999',
                     title_tesim: ['My Title'],
                     creator_tesim: ['Doe, John', 'Doe, Jane'],
                     date_modified_dtsi: '2011-04-01',
                     has_model_ssim: ['Media'],
                     depositor_tesim: depositor.user_key,
                     description_tesim: ['Lorem ipsum lorem ipsum.'],
                     keyword_tesim: ['bacon', 'sausage', 'eggs'],
                     rights_statement_tesim: ['http://example.org/rs/1'],
                     date_created_tesim: ['1984-01-02'])
  end

  let(:depositor) do
    FactoryBot.build(:user)
  end

  let(:ability) { double }

  let(:request) { double('request', host: 'test.host') }

  let(:test_presenter) do
    Hyrax::MediaPresenter.new(work_solr_document, ability, request)
  end

  describe "manifest builder " do
    it "is a IIIFManifest::ManifestBuilder object" do
      allow(subject).to receive(:presenter).and_return(test_presenter)
      expect(subject.send(:manifest_builder)).to be_a IIIFManifest::ManifestBuilder
    end
  end

  describe "#valid_file_formats" do
    let(:work)        { Media.new(title: ["Test Media Work"]) }
    let(:user)        { FactoryBot.create(:user) }
    let(:file_path1)  { fixture_path + '/images/duke.png' }
    let(:file_path2)  { fixture_path + '/images/ms.jpg' }
    let(:file_path3)  { fixture_path + '/images/ms_2.jpg' }
    let(:local_file1) { File.open(file_path1) }
    let(:local_file2) { File.open(file_path2) }
    let(:local_file3) { File.open(file_path3) }
    let(:upload1)     { Hyrax::UploadedFile.create(user_id: user.id, file: local_file1) }
    let(:upload2)     { Hyrax::UploadedFile.create(user_id: user.id, file: local_file2) }
    let(:upload3)     { Hyrax::UploadedFile.create(user_id: user.id, file: local_file3) }
    let(:uploaded_file_ids) { [upload1.id, upload2.id, upload3.id] }

    before do
      allow(subject).to receive(:curation_concern).and_return(work)
    end

    context "Uploaded files are correct for the selected media type" do
      before do
        allow(subject).to receive(:attributes_for_actor).and_return( { "media_type"=>["Image"], "uploaded_files"=> uploaded_file_ids})
      end

      it "returns true" do
        expect(subject.send(:file_formats_valid?)).to be(true)
      end
    end

    context "Uploaded files are incorrect for the selected media type" do
      before do
        allow(subject).to receive(:attributes_for_actor).and_return( { "media_type"=>["Video"], "uploaded_files"=> uploaded_file_ids})
      end

      it "returns false if the uploaded file formats are correct for the selected media type" do
        expect(subject.send(:file_formats_valid?)).to be(false)
      end

      it "adds a base error if the uploaded file formats are incorrect" do
        subject.send(:file_formats_valid?)
        expect(subject.curation_concern.errors[:base][0]).to include("duke.png","ms.jpg","ms_2.jpg")
      end
    end
  end
end
