# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  # Generated form for Media
  class MediaForm < Hyrax::Forms::WorkForm
    self.model_class = ::Media
    self.terms += [:resource_type]
  end
end
