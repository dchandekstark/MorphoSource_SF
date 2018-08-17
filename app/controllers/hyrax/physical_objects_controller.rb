# Generated via
#  `rails generate hyrax:work PhysicalObject`
module Hyrax
  # Generated controller for PhysicalObject
  class PhysicalObjectsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PhysicalObject

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PhysicalObjectPresenter
  end
end
