# Generated via
#  `rails generate hyrax:work Attachment`
module Hyrax
  # Generated controller for Attachment
  class AttachmentsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::Attachment

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::AttachmentPresenter
  end
end
