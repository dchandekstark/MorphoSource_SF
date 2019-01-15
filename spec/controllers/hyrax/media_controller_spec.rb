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
    let(:file_path4)  { fixture_path + '/ms.zip'}
    let(:local_file1) { File.open(file_path1) }
    let(:local_file2) { File.open(file_path2) }
    let(:local_file3) { File.open(file_path3) }
    let(:local_file4) { File.open(file_path4) }

    # New uploads
    let(:upload1)     { Hyrax::UploadedFile.create(user_id: user.id, file: local_file1) }
    let(:upload2)     { Hyrax::UploadedFile.create(user_id: user.id, file: local_file2) }
    let(:uploaded_file_ids) { [upload1.id, upload2.id] }

    # Previous uploads
    let(:file_set_1)   { FileSet.new }
    let(:file_set_3)   { FileSet.new }
    let(:file_set_4)   { FileSet.new }

    before do
      allow(subject).to receive(:curation_concern).and_return(work)
      Hydra::Works::AddFileToFileSet.call(file_set_1, local_file1, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_3, local_file3, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_4, local_file4, :original_file, versioning: true)
    end

    context "Previously uploaded files and new uploads are correct for the selected media type" do
      before do
        allow(subject).to receive(:attributes_for_actor).and_return( { "media_type"=>["Image"], "uploaded_files"=>uploaded_file_ids} )
        work.ordered_members << file_set_1 << file_set_3
      end

      it "returns true" do
        expect(subject.send(:file_formats_valid?)).to be(true)
      end

      it "has no base errors" do
        subject.send(:file_formats_valid?)
        expect(subject.curation_concern.errors[:base]).to match_array( [] )
      end
    end

    context "Previously uploaded files and new uploads are incorrect for the selected media type" do
      before do
        allow(subject).to receive(:attributes_for_actor).and_return( { "media_type" => ["Video"], "uploaded_files" => uploaded_file_ids} )
        work.ordered_members << file_set_1 << file_set_3
      end

      it "returns false" do
        expect(subject.send(:file_formats_valid?)).to be(false)
      end

      it "adds all the filenames to a base error" do
        subject.send(:file_formats_valid?)
        expect(subject.curation_concern.errors[:base][0]).to include("duke.png","ms.jpg","ms_2.jpg")
      end
    end

    context "Previously uploaded files are correct and new uploads are incorrect for the selected media type" do
      before do
        allow(subject).to receive(:attributes_for_actor).and_return( { "media_type" => ["CTImageStack"], "uploaded_files" => uploaded_file_ids} )
        work.ordered_members << file_set_4
      end

      it "returns false" do
        expect(subject.send(:file_formats_valid?)).to be(false)
      end

      it "adds the newly uploaded filenames to a base error" do
        subject.send(:file_formats_valid?)
        expect(subject.curation_concern.errors[:base][0]).to include("duke.png","ms.jpg")
      end
    end

    context "Previously uploaded files are incorrect and new uploads are correct for the selected media type" do
      before do
        allow(subject).to receive(:attributes_for_actor).and_return( { "media_type" => ["Image"], "uploaded_files" => uploaded_file_ids} )
        work.ordered_members << file_set_4
      end

      it "returns false" do
        expect(subject.send(:file_formats_valid?)).to be(false)
      end

      it "adds the previously uploaded filenames to a base error" do
        subject.send(:file_formats_valid?)
        expect(subject.curation_concern.errors[:base][0]).to include("ms.zip")
      end
    end
  end

  describe "#set_fileset_visibility" do
    let(:work)        { Media.new(title: ["Test Media Work"]) }
    before do
      allow(subject).to receive(:curation_concern).and_return(work)
    end

    context 'when user selects same file visibility as the work visibility' do
      before do
        allow(subject).to receive(:params).and_return({"media"=> {"fileset_visibility" => "default"}})
      end
      it 'sets curation_concern.fileset_visibility to an array containing an empty string' do
        subject.send(:set_fileset_visibility)
        expect(subject.curation_concern.fileset_visibility).to match_array([""])
      end
    end
    context 'when user selects private file visibility' do
      before do
        allow(subject).to receive(:params).and_return({"media"=> {"fileset_visibility" => "restricted"}})
      end
      it 'sets curation_concern.fileset_visibility to an array containing "restricted"' do
        subject.send(:set_fileset_visibility)
        expect(subject.curation_concern.fileset_visibility).to match_array(["restricted"])
      end
    end
  end
end
