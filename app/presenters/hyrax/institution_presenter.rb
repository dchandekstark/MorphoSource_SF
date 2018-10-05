# Generated via
#  `rails generate hyrax:work Institution`
module Hyrax
  class InstitutionPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods
    class_attribute :work_presenter_class

    self.work_presenter_class = InstitutionPresenter

    delegate :institution_code, :address, :city, :state_province, :country, to: :solr_document
  end
end
