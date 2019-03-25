# Generated via
#  `rails generate hyrax:work Taxonomy`
require 'rails_helper'

RSpec.describe Hyrax::TaxonomyPresenter do

  let(:work) { Taxonomy.new() }
  let(:taxonomy_terms) {[:taxonomy_domain, :taxonomy_kingdom, :taxonomy_phylum, :taxonomy_superclass, :taxonomy_class, :taxonomy_subclass, :taxonomy_superorder, :taxonomy_order, :taxonomy_suborder, :taxonomy_superfamily, :taxonomy_family, :taxonomy_subfamily, :taxonomy_tribe, :taxonomy_genus, :taxonomy_subgenus, :taxonomy_species, :taxonomy_subspecies, :trusted]}

  subject { described_class.new(SolrDocument.new(work.to_solr), nil) }

  it 'delegates all the terms to solr' do
    taxonomy_terms.each do |method|
      expect(subject).to delegate_method(method).to(:solr_document)
    end
  end

end
