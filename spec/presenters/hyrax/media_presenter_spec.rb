# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'

RSpec.describe Hyrax::MediaPresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }
  let(:user_key) { 'a_user_key' }
  let(:attributes) do
    { "id" => '888888',
      "title_tesim" => ['foo', 'bar'],
      "human_readable_type_tesim" => ["Generic Work"],
      "has_model_ssim" => ["GenericWork"],
      "date_created_tesim" => ['an unformatted date'],
      "depositor_tesim" => user_key }
  end
  let(:ability) { double Ability }
  let(:presenter) { described_class.new(solr_document, ability, request) }

	describe '#universal_viewer?' do
    let(:id_present) { false }
    let(:representative_presenter) { double('representative', present?: false) }
    let(:image_boolean) { false }
    let(:mesh_boolean) { false }
    let(:iiif_enabled) { true }
    let(:file_set_presenter) { Hyrax::MediaFileSetPresenter.new(solr_document, ability) }
    let(:file_set_presenters) { [file_set_presenter] }
    let(:read_permission) { true }

    before do
      allow(presenter).to receive(:representative_id).and_return(id_present)
      allow(presenter).to receive(:representative_presenter).and_return(representative_presenter)
      allow(presenter).to receive(:file_set_presenters).and_return(file_set_presenters)
      allow(file_set_presenter).to receive(:image?).and_return(true)
      allow(file_set_presenter).to receive(:mesh?).and_return(true)
      allow(ability).to receive(:can?).with(:read, solr_document.id).and_return(read_permission)
      allow(representative_presenter).to receive(:image?).and_return(image_boolean)
      allow(representative_presenter).to receive(:mesh?).and_return(mesh_boolean)
      allow(Hyrax.config).to receive(:iiif_image_server?).and_return(iiif_enabled)
    end

    subject { presenter.universal_viewer? }

    context 'with no representative_id' do
      it { is_expected.to be false }
    end

    context 'with no representative_presenter' do
      let(:id_present) { true }

      it { is_expected.to be false }
    end

    context 'with non-image and non-mesh representative_presenter' do
      let(:id_present) { true }
      let(:representative_presenter) { double('representative', present?: true) }
      let(:image_boolean) { false }
      let(:mesh_boolean) { false }

      it { is_expected.to be false }
    end

    context 'with IIIF image server turned off' do
      let(:id_present) { true }
      let(:representative_presenter) { double('representative', present?: true) }
      let(:image_boolean) { true }
      let(:iiif_enabled) { false }

      it { is_expected.to be false }
    end

    context 'with representative image and IIIF turned on' do
      let(:id_present) { true }
      let(:representative_presenter) { double('representative', present?: true) }
      let(:image_boolean) { true }
      let(:mesh_boolean) { false }
      let(:iiif_enabled) { true }

      it { is_expected.to be true }

      context "when the user doesn't have permission to view the image" do
        let(:read_permission) { false }

        it { is_expected.to be false }
      end
    end

    context 'with representative mesh and IIIF turned on' do
      let(:id_present) { true }
      let(:representative_presenter) { double('representative', present?: true) }
      let(:image_boolean) { false }
      let(:mesh_boolean) { true }
      let(:iiif_enabled) { true }

      it { is_expected.to be true }

      context "when the user doesn't have permission to view the image" do
        let(:read_permission) { false }

        it { is_expected.to be false }
      end
    end
  end

  describe "media member presenter" do
  	subject { presenter }

  	it "is a Hyrax::MediaMemberPresenterFactory object" do
  		expect(presenter.send(:member_presenter_factory)).to be_a Hyrax::MediaMemberPresenterFactory
  	end
  end

  
end
