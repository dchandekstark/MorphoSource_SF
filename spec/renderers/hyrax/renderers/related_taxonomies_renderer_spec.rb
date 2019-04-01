require 'rails_helper'
require 'equivalent-xml'


RSpec.describe Hyrax::Renderers::RelatedTaxonomiesRenderer do

  let(:field)             { :biological_specimens }

  let(:taxonomy)          { Taxonomy.new(id: "def456", title: ["Domain > Kingdom > Phylum"])}
  let(:canonical_taxonomy){ Taxonomy.new(id: "ghi789", title: ["Superclass > Class > Subclass"]) }
  let(:trusted_taxonomy)  { Taxonomy.new(id: "jkl123", title: ["Superorder > Order > Suborder"]) }
  let(:user_taxonomy)     { Taxonomy.new(id: "mno456", title: ["Superfamily > Family > Subfamily"]) }

  let(:child_specimen)    { BiologicalSpecimen.create(id: "abc123", title: ["test biological specimen"] ) }

  let(:renderer)          { described_class.new(field, [child_specimen], locale: :en, id: taxonomy.id) }

  let(:taxonomy_methods)  {[:canonical_taxonomy_object, :trusted_taxonomies, :user_taxonomies]}

  let(:subject)           { Nokogiri::HTML(renderer.render) }

  it 'delegates taxonomy methods to @specimen' do
    taxonomy_methods.each do |method|
      expect(@specimen).to receive(method)
      renderer.send(method)
    end
  end

  describe "#attribute_value_to_html" do
    let(:expected) { Nokogiri::HTML(tr_content) }

    before do
      allow(child_specimen).to receive(:canonical_taxonomy_object).and_return(canonical_taxonomy)
      allow(child_specimen).to receive(:trusted_taxonomies).and_return([canonical_taxonomy])
      allow(child_specimen).to receive(:user_taxonomies).and_return([trusted_taxonomy])
    end

    let(:tr_content) do
      %(<div class="row">
          <div class="col-xs-6 showcase-label">Biological specimens</div>
          <div class="col-xs-6 showcase-value">
          <span></span> 
          <span class="showcase-link">
            <a href="/concern/biological_specimens/abc123?locale=en">test biological specimen</a>
          </span>
          <ul>
            <span>Institutional </span> 
            <span class="showcase-link">
              <a href="/concern/taxonomies/ghi789?locale=en">Superclass &gt; Class &gt; Subclass</a>
            </span>
          </ul>
          <ul>
            <span>MorphoSource Inferred </span> 
            <span class="showcase-link">
              <a href="/concern/taxonomies/ghi789?locale=en">Superclass &gt; Class &gt; Subclass</a>
            </span>
          </ul>
          <ul>
            <span>User-Supplied </span> 
            <span class="showcase-link">
              <a href="/concern/taxonomies/jkl123?locale=en">Superorder &gt; Order &gt; Suborder</a>
            </span>
          </ul>
        </div>
       </div>)
    end

    it { expect(subject).to be_equivalent_to(expected) }
  end


end
