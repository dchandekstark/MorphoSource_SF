require 'iiif_manifest'
require 'rails_helper'

RSpec.describe Hyrax::MediaFileSetPresenter do
	let(:solr_document) { SolrDocument.new(attributes) }
  let(:ability) { double "Ability" }
  let(:presenter) { described_class.new(solr_document, ability, request) }
  let(:attributes) { {} }
  # let(:file) do
  #   build(:file_set,
  #         id: '123abc',
  #         user: user,
  #         title: ["File title"],
  #         depositor: user.user_key,
  #         label: "filename.tif")
  # end
  let(:user) { double(user_key: 'julie') }
  let(:request) { double(base_url: 'http://test.host') }
  let(:id) { '999' }
  let(:read_permission) { true }

  describe 'IIIF integration' do
    # let(:file_set) { create(:file_set) }
    # let(:solr_document) { SolrDocument.new(file_set.to_solr) }
    
    before do
      allow(ability).to receive(:can?).with(:read, solr_document.id).and_return(read_permission)
    end

    describe "#display_mesh" do
      subject { presenter.display_mesh }

      context 'without a file' do
        let(:id) { 'bogus' }

        it { is_expected.to be_nil }
      end

      context 'with a file' do
        context "when the file is not an image" do
          let(:attributes) { {
  									  id: '999',
                      title_tesim: ['test.txt'],
                      creator_tesim: ['Doe, John', 'Doe, Jane'],
                      date_modified_dtsi: '2011-04-01',
                      has_model_ssim: ['Media'],
                      depositor_tesim: user.user_key,
                      description_tesim: ['Lorem ipsum lorem ipsum.'],
                      keyword_tesim: ['bacon', 'sausage', 'eggs'],
                      rights_statement_tesim: ['http://example.org/rs/1'],
                      date_created_tesim: ['1984-01-02']
                     } }

          it { is_expected.to be_nil }
        end

        context "when the file is a mesh" do
          let(:attributes) { {
  									  id: '999',
                      title_tesim: ['test.ply'],
                      label_tesim: ['test.ply'],
                      creator_tesim: ['Doe, John', 'Doe, Jane'],
                      date_modified_dtsi: '2011-04-01',
                      has_model_ssim: ['Media'],
                      depositor_tesim: user.user_key,
                      description_tesim: ['Lorem ipsum lorem ipsum.'],
                      keyword_tesim: ['bacon', 'sausage', 'eggs'],
                      rights_statement_tesim: ['http://example.org/rs/1'],
                      date_created_tesim: ['1984-01-02']
                     } }

          before do
            allow(solr_document).to receive(:mesh?).and_return(true)
            allow(::FileSet).to receive(:exists?).with(solr_document.id).and_return(true)
          end

          it { is_expected.to be_instance_of IIIFManifest::DisplayMesh }
          its(:url) { is_expected.to eq "http://test.host/downloads/#{id}" }

          context "when the user doesn't have permission to view the image" do
            let(:read_permission) { false }

            it { is_expected.to be_nil }
          end
        end
      end
    end
  end
end