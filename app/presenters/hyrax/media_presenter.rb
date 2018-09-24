# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  class MediaPresenter < Hyrax::WorkShowPresenter

  	def universal_viewer?
      representative_id.present? &&
        representative_presenter.present? &&
        (representative_presenter.image? || representative_presenter.mesh?) &&
        Hyrax.config.iiif_image_server? &&
        (members_include_viewable_image? || members_include_viewable_mesh?)
   	end

  	private
			def member_presenter_factory
        MediaMemberPresenterFactory.new(solr_document, current_ability, request)
			end

			def members_include_viewable_mesh?
      	file_set_presenters.any? { |presenter| presenter.mesh? && current_ability.can?(:read, presenter.id) }
      end
  end
end
