# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  class MediaPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :agreement_uri, :cite_as, :funding, :map_type, :media_type, :modality, :orientation, :part, :rights_holder, :scale_bar, :series_type, :side, :unit, :x_spacing, :y_spacing, :z_spacing, :slice_thickness, :identifier, :related_url, to: :solr_document

    attr_accessor :physical_object_type, :idigbio_uuid

    def universal_viewer?
      representative_id.present? &&
        representative_presenter.present? &&
        (representative_presenter.image? || representative_presenter.mesh?) &&
        Hyrax.config.iiif_image_server? &&
        (members_include_viewable_image? || members_include_viewable_mesh?)
    end

    def get_showcase_data
      # Get the physical object type from:
      # Media < ImagingEvent < BiologicalSpecimen (or CulturalHeritageObject)
      imaging_event = ImagingEvent.where('member_ids_ssim' => solr_document.id).first
      if imaging_event.present?
        biological_specimen = BiologicalSpecimen.where('member_ids_ssim' => imaging_event.id).first
        cultural_heritage_object = CulturalHeritageObject.where('member_ids_ssim' => imaging_event.id).first

        if biological_specimen.present?
          @idigbio_uuid = biological_specimen.idigbio_uuid
          @physical_object_type = "BiologicalSpecimen"
        elsif cultural_heritage_object.present?
          @idigbio_uuid = cultural_heritage_object.idigbio_uuid
          @physical_object_type = "CulturalHeritageObject"
        end
      end        
    end

    def supplied_record_badge
      # this method over the method in presents_attributes, passing the idigbio_uuid retrieved from get_showcase_data
      supplied_record_badge_class.new(@idigbio_uuid).render
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
