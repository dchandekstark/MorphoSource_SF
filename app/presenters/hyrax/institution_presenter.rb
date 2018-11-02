# Generated via
#  `rails generate hyrax:work Institution`
module Hyrax
  class InstitutionPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :institution_code, :address, :city, :state_province, :country, to: :solr_document
  end
end
