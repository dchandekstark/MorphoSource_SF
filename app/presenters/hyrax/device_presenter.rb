# Generated via
#  `rails generate hyrax:work Device`
module Hyrax
  class DevicePresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods
    class_attribute :work_presenter_class

    self.work_presenter_class = DevicePresenter

    delegate :facility, :modality, to: :solr_document
  end
end
