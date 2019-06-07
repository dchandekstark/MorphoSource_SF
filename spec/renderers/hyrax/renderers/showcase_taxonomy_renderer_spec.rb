require 'rails_helper'
require 'equivalent-xml'

RSpec.describe Hyrax::Renderers::ShowcaseTaxonomyRenderer do

  let(:full_attrs) {{
    id: 'abc123',
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

  let(:some_attrs) {{
    id: 'def456',
    title: ["domain2 > kingdom2 > genus2 > species2"],
    taxonomy_domain: [],
    taxonomy_kingdom: ["kingdom"],
    taxonomy_phylum: ["phylum"],
    taxonomy_superclass: [],
    taxonomy_class: ["class"],
    taxonomy_subclass: [],
    taxonomy_superorder: [],
    taxonomy_order: ["order"],
    taxonomy_suborder: [],
    taxonomy_superfamily: [],
    taxonomy_family: ["family"],
    taxonomy_subfamily: [],
    taxonomy_tribe: [],
    taxonomy_genus: ["genus"],
    taxonomy_subgenus: [],
    taxonomy_species: ["species"],
    taxonomy_subspecies: [] }}



end
