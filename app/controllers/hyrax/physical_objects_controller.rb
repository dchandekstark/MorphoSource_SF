module Hyrax
  class PhysicalObjectsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::BiologicalSpecimen

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::BiologicalSpecimenPresenter
  end
end
