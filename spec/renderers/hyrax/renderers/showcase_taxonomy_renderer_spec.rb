require 'rspec/matchers'
require 'rails_helper'
require 'equivalent-xml'


RSpec.describe Hyrax::Renderers::ShowcaseTaxonomyRenderer do
  let(:field)               { :canonical_taxonomy_object }
  let(:attrs) {{
    title: ["domain > kingdom > genus > species"],
    taxonomy_domain: ["domain"],
    taxonomy_kingdom: ["kingdom"],
    taxonomy_phylum: ["phylum"],
    taxonomy_superclass: ["superclass"],
    taxonomy_class: ["class"],
    taxonomy_subclass: ["subclass"],
    taxonomy_superorder: ["superorder"],
    taxonomy_order: ["order"],
    taxonomy_suborder: ["suborder"],
    taxonomy_superfamily: ["superfamily"],
    taxonomy_family: ["family"],
    taxonomy_subfamily: ["subfamily"],
    taxonomy_tribe: ["tribe"],
    taxonomy_genus: ["genus"],
    taxonomy_subgenus: ["subgenus"],
    taxonomy_species: ["species"],
    taxonomy_subspecies: ["subspecies"] }}
  let(:canonical_taxonomy_object)  { Taxonomy.new(attrs) }
  let(:renderer)  { described_class.new(field, [canonical_taxonomy_object], data_parent: "taxonomy-accordion-group", label: "Institutional", is_collapsed: true) }

  describe "#render" do
    subject                 { Nokogiri::HTML(renderer.render) }
    let(:expected)          { Nokogiri::HTML(content) }
    let(:block)             { "collapse-taxonomy-imxatwyl" }

    before do
      allow_any_instance_of(described_class).to receive(:create_block).and_return(block)
    end

    let(:content) do
      %(<div class="panel">
          <a data-toggle="collapse" data-parent="#taxonomy-accordion-group" href="#collapse-taxonomy-imxatwyl">
            <div class="row">
              <div class="col-xs-6 showcase-label">Institutional</div>
              <div class="col-xs-5 showcase-value taxonomy-title">genus subgenus species subspecies</div>
              <span class="col-xs-1 glyphicon glyphicon-triangle-bottom collapse-taxonomy-imxatwyl"></span>
            </div>
           </a>
           <div id="collapse-taxonomy-imxatwyl" class="panel-collapse collapse collapse-accordion">
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Domain</div>
            <div class="col-xs-6 showcase-value">domain</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Kingdom</div>
            <div class="col-xs-6 showcase-value">kingdom</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Phylum</div>
            <div class="col-xs-6 showcase-value">phylum</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Superclass</div>
            <div class="col-xs-6 showcase-value">superclass</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Class</div>
            <div class="col-xs-6 showcase-value">class</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Subclass</div>
            <div class="col-xs-6 showcase-value">subclass</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Superorder</div>
            <div class="col-xs-6 showcase-value">superorder</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Order</div>
            <div class="col-xs-6 showcase-value">order</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Suborder</div>
            <div class="col-xs-6 showcase-value">suborder</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Superfamily</div>
            <div class="col-xs-6 showcase-value">superfamily</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Family</div>
            <div class="col-xs-6 showcase-value">family</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Subfamily</div>
            <div class="col-xs-6 showcase-value">subfamily</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Tribe</div>
            <div class="col-xs-6 showcase-value">tribe</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Genus</div>
            <div class="col-xs-6 showcase-value">genus</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Subgenus</div>
            <div class="col-xs-6 showcase-value">subgenus</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Species</div>
            <div class="col-xs-6 showcase-value">species</div>
           </div>
           <div class="row taxonomy-rank">
            <div class="col-xs-6 showcase-label">Subspecies</div>
            <div class="col-xs-6 showcase-value">subspecies</div>
           </div>
          </div>
        </div>)
    end

    it { expect(subject).to be_equivalent_to(expected) }

  end
end
