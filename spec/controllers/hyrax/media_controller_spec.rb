# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'
require 'iiif_manifest'

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
end
