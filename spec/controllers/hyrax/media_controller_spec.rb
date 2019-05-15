# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'
require 'iiif_manifest'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Hyrax::MediaController, type: :controller do
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

  let(:test_presenter) do
    Hyrax::MediaPresenter.new(work_solr_document, ability, request)
  end

  describe "manifest builder " do
    it "is a IIIFManifest::ManifestBuilder object" do
      allow(subject).to receive(:presenter).and_return(test_presenter)
      expect(subject.send(:manifest_builder)).to be_a IIIFManifest::ManifestBuilder
    end
  end

  describe "GET #zip" do
    let(:work1)       { Media.new(title: ["Test Media Work"], id: 'tmw1', depositor: 'example@example.com') }
    let(:work2)       { Media.new(title: ["Test Media Work 2"], id: 'tmw2', depositor: 'example@example.com') }
    let(:work_dup)    { Media.new(title: ["Test Media Work"], id: 'tmw3', depositor: 'example@example.com') }
    let(:solr_doc1)   { SolrDocument.new(work1.to_solr) }
    let(:solr_doc2)   { SolrDocument.new(work2.to_solr) }
    let(:solr_doc_dup){ SolrDocument.new(work_dup.to_solr) }
    let(:file_path1)  { fixture_path + '/images/duke.png' }
    let(:file_path2)  { fixture_path + '/images/ms.jpg' }
    let(:file_path3)  { fixture_path + '/images/ms_2.jpg' }
    let(:local_file1) { File.open(file_path1) }
    let(:local_file2) { File.open(file_path2) }
    let(:local_file3) { File.open(file_path3) }
    let(:local_file_dup) { File.open(file_path1) }

    let(:ability) { double Ability }

    let(:file_set_1)   { FileSet.new }
    let(:file_set_2)   { FileSet.new }
    let(:file_set_3)   { FileSet.new }
    let(:file_set_dup) { FileSet.new }

    before do
      sign_in depositor
      Hydra::Works::AddFileToFileSet.call(file_set_1, local_file1, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_2, local_file2, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_3, local_file3, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_dup, local_file_dup, :original_file, versioning: true)
      allow(ability).to receive(:can?).with(:read, solr_doc1.id).and_return(true)
      allow(ability).to receive(:can?).with(:read, solr_doc2.id).and_return(true)
      allow(ability).to receive(:can?).with(:read, solr_doc_dup.id).and_return(true)
      work1.ordered_members << file_set_1 << file_set_2
      work2.ordered_members << file_set_3
      work_dup.ordered_members << file_set_dup
    end

    it "returns a zip for a single work" do
      get :zip, params: { ids: [work1.id] }
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/zip")
      expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource-')
      expect(response.headers["Content-Disposition"]).to end_with('.zip"')
    end

    it "returns a zip for multiple works" do
      get :zip, params: { ids: [work1.id, work2.id] }
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/zip")
      expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource-')
      expect(response.headers["Content-Disposition"]).to end_with('.zip"')
    end

    it "returns a zip for duplicated works" do
      get :zip, params: { ids: [work1.id, work1.id] }
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/zip")
      expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource-')
      expect(response.headers["Content-Disposition"]).to end_with('.zip"')
    end

    it "returns a zip for unique works with conflicting names" do
      get :zip, params: { ids: [work1.id, work_dup.id] }
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/zip")
      expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource-')
      expect(response.headers["Content-Disposition"]).to end_with('.zip"')
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
        allow(subject).to receive(:attributes_for_actor).and_return( { "media_type" => ["CTImageSeries"], "uploaded_files" => uploaded_file_ids} )
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

  describe '#after_update_response' do
    let(:curation_concern) { Media.create(title: ["title"]) }
    let(:actor) { double(update: true) }

    routes { Rails.application.routes }
    let(:main_app) { Rails.application.routes.url_helpers }
    let(:hyrax) { Hyrax::Engine.routes.url_helpers }

    let(:file_path1)  { fixture_path + '/images/duke.png' }
    let(:file_path2)  { fixture_path + '/images/ms.jpg' }
    let(:file_path3)  { fixture_path + '/images/ms_2.jpg' }
    let(:local_file1) { File.open(file_path1) }
    let(:local_file2) { File.open(file_path2) }
    let(:local_file3) { File.open(file_path3) }
    let(:file_set_1)   { FileSet.new(visibility: "open") }
    let(:file_set_2)   { FileSet.new(visibility: "open") }
    let(:file_set_3)   { FileSet.new(visibility: "open") }

    before do
      sign_in depositor
      allow(Hyrax::CurationConcern).to receive(:actor).and_return(actor)
      allow(Media).to receive(:find).and_return(curation_concern)
      allow(curation_concern).to receive(:visibility_changed?).and_return(false)
      allow(controller).to receive(:authorize!).with(:update, curation_concern).and_return(true)
      # allow(curation_concern).to receive(:file_sets).and_return(double(present?: true))
      Hydra::Works::AddFileToFileSet.call(file_set_1, local_file1, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_2, local_file2, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_3, local_file3, :original_file, versioning: true)
      curation_concern.ordered_members << file_set_1 << file_set_2 << file_set_3

      allow(subject).to receive(:attributes_for_actor).and_return( { "media_type" => ["Image"]} )
    end

    # Meets one of the conditions to update file visibility
    context 'saved fileset_visibility is changed' do
      context 'the user selects the same fileset visibility as the work' do
        before do
          # results in fileset_visibility_changed? being true
          curation_concern.fileset_visibility = ["restricted"]
        end

        context 'the work permissions are unchanged' do
          before do
            allow(controller).to receive(:permissions_changed?).and_return(false)
            patch :update, params: { id: curation_concern, media: {fileset_visibility: "default"}, action: "update" }
          end

          it 'redirects to permissions/#copy' do
            expect(response).to redirect_to(main_app.copy_hyrax_permission_path(curation_concern, locale: 'en'))
          end
        end

        context 'the work permissions change' do
          before do
            allow(controller).to receive(:permissions_changed?).and_return(true)
            patch :update, params: { id: curation_concern, media: {fileset_visibility: "default"}, action: "update" }
          end

          it 'redirects to permissions/#copy_access' do
            expect(response).to redirect_to(hyrax.copy_access_permission_path(curation_concern, locale: 'en'))
          end
        end
      end

      context 'the user restricts the file visibility' do
        before do
          # results in fileset_visibility_changed? being true
          curation_concern.fileset_visibility = [""]
        end

        context 'the work permissions change' do
          before do
            allow(controller).to receive(:permissions_changed?).and_return(true)
          end

          it 'calls the InheritPermissionsJob' do
            expect(InheritPermissionsJob).to receive(:perform_later).with(curation_concern)
            patch :update, params: { id: curation_concern, media: {fileset_visibility: "restricted"}, action: "update" }
          end
        end

        context 'the work permissions do not change' do
          before do
            allow(controller).to receive(:permissions_changed?).and_return(false)
          end

          it 'calls the InheritPermissionsJob' do
            expect(InheritPermissionsJob).not_to receive(:perform_later).with(curation_concern)
            patch :update, params: { id: curation_concern, media: {fileset_visibility: "restricted"}, action: "update" }
          end
        end

        it "sets the work's filesets' visibilities to 'restricted'" do
          patch :update, params: { id: curation_concern, media: {fileset_visibility: "restricted"}, action: "update" }
          expect(file_set_1.visibility).to eq("restricted")
          expect(file_set_2.visibility).to eq("restricted")
          expect(file_set_3.visibility).to eq("restricted")
        end

        it 'redirects to the work show page' do
          patch :update, params: { id: curation_concern, media: {fileset_visibility: "restricted"}, action: "update" }
          expect(response).to redirect_to main_app.hyrax_media_path(curation_concern, locale: 'en')
        end

        it 'displays a flash message' do
          patch :update, params: { id: curation_concern, media: {fileset_visibility: "restricted"}, action: "update" }
          expect(response.flash[:notice]).to eq('Updating file permissions to restricted. This may take a few minutes. You may want to refresh your browser or return to this record later to see the updated file permissions.')
        end
      end
    end

    context 'fileset_visibility_changed? and curation_concern.visibility_changed? are false' do

      context 'the user selects the same fileset visibility as the work' do
        before do
          # results in fileset_visibility_changed? being false
          curation_concern.fileset_visibility = [""]
          patch :update, params: { id: curation_concern, media: {fileset_visibility: "default"}, action: "update" }
        end

        it 'redirects to the work show page' do
          expect(response).to redirect_to main_app.hyrax_media_path(curation_concern, locale: 'en')
        end

        it 'displays a flash message' do
          expect(response.flash[:notice]).to eq("Work \"#{curation_concern}\" successfully updated.")
        end
      end

      context 'the user restricts the file visibility' do
        before do
          # results in fileset_visibility_changed? being false
          curation_concern.fileset_visibility = ["restricted"]
          patch :update, params: { id: curation_concern, media: {fileset_visibility: "restricted"}, action: "update" }
        end

        it 'redirects to the work show page' do
          expect(response).to redirect_to main_app.hyrax_media_path(curation_concern, locale: 'en')
        end

        it 'displays a flash message' do
          expect(response.flash[:notice]).to eq("Work \"#{curation_concern}\" successfully updated.")
        end
      end
    end
  end
end
