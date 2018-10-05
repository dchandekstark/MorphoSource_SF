# Generated via
#  `rails generate hyrax:work Attachment`
module Hyrax
  class AttachmentPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods
    class_attribute :work_presenter_class

    self.work_presenter_class = AttachmentPresenter


  end
end
