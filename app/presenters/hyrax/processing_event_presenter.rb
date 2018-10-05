# Generated via
#  `rails generate hyrax:work ProcessingEvent`
module Hyrax
  class ProcessingEventPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods
    class_attribute :work_presenter_class

    self.work_presenter_class = ProcessingEventPresenter

    delegate :software, to: :solr_document
  end
end
