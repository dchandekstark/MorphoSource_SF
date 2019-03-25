# Generated via
#  `rails generate hyrax:work Taxonomy`
module Hyrax
  # Generated form for Taxonomy
  class TaxonomyForm < Hyrax::Forms::WorkForm
    self.model_class = ::Taxonomy
    self.terms += [:resource_type]
  end
end
