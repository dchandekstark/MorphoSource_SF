# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  # Generated controller for BiologicalSpecimen
  class BiologicalSpecimensController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Hyrax::ChildWorkRedirect
    self.curation_concern_type = ::BiologicalSpecimen

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::BiologicalSpecimenPresenter

    def showcase
#       @presenter = Hyrax::BiologicalSpecimenPresenter
       @presenter = show_presenter.new(curation_concern_from_search_results, current_ability, request)

      render '/hyrax/physical_objects/showcase', presenter: @presenter
    end
  end

end
