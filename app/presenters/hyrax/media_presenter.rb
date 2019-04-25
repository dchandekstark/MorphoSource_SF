# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  class MediaPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :agreement_uri, :cite_as, :funding, :map_type, :media_type, :modality, :orientation, :part, :rights_holder, :scale_bar, :series_type, :side, :unit, :x_spacing, :y_spacing, :z_spacing, :slice_thickness, :identifier, :related_url, to: :solr_document

    attr_accessor :physical_object_type, :idigbio_uuid, :vouchered, :physical_object_title, :physical_object_link, :physical_object_id, :device_title, :device_facility, :device_link, :device, :parent_media_id_list, :child_media_id_list,
      :sibling_media_id_list, :parent_media_count, :direct_parent_title_list, :processing_event_count, :data_managed_by,
      :download_permission, :ark, :doi

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
          @physical_object_title = biological_specimen.title.first
          @physical_object_id = biological_specimen.id
          @physical_object_link = "/concern/biological_specimens/" + @physical_object_id
          @idigbio_uuid = biological_specimen.idigbio_uuid
          @vouchered = biological_specimen.vouchered
          @physical_object_type = "BiologicalSpecimen"
        elsif cultural_heritage_object.present?
          @physical_object_title = cultural_heritage_object.title.first
          @physical_object_id = cultural_heritage_object.id
          @physical_object_link = "/concern/cultural_heritage_object/" + @physical_object_id
          @idigbio_uuid = cultural_heritage_object.idigbio_uuid
          @vouchered = cultural_heritage_object.vouchered
          @physical_object_type = "CulturalHeritageObject"
        end

        # get device from imaging event
        device = Device.where('member_ids_ssim' => imaging_event.id).first
        if device.present?
          @device_title = device.title.first
          @device_facility = device.facility.first
          @device = device.title.first + " (" + device.facility.first + ")"
          @device_link = "/concern/devices/" + device.id
        end
      end # end if imaging_event present?
      
      # add current media id, then add child media ids.  
      # currently add up to 5 levels in the tree.  Later we should store the child medias in the work
      # so there is no need to traverse the tree
      media = Media.where('id' => solr_document.id).first
      @parent_media_id_list = parent_media_ids(media, 5, []).flatten.uniq
      @parent_media_count = @parent_media_id_list.length.to_s
      @child_media_id_list = child_media_ids(media, 5, []).flatten.uniq
      @sibling_media_id_list = sibling_media_ids(media, []).flatten.uniq

      # get direct parents
      # todo: setup links using the media ids
      @direct_parent_id_list = parent_media_ids(media, 1, []).flatten.uniq
      @direct_parent_title_list = []
      @direct_parent_id_list.each do |parent_id|
        parent_media = Media.where('id' => parent_id).first
        @direct_parent_title_list << parent_media.title.first
      end

      @processing_event_count = 0
      media.member_ids.each do |id|
        processing_event = nil
        if ProcessingEvent.where('id' => id).present? 
          processing_event = ProcessingEvent.where('id' => id).first
        end
        if processing_event.present?
          @processing_event_count += 1
        end
      end # end media.member_ids.each

      # todo: need to get the user name (and a link to user) from the email address
      @data_managed_by = solr_document.depositor
      
      if media.fileset_visibility.include? 'restricted'
        @download_permission = 'restricted'
      else
        @download_permission = 'open'
      end

      @ark = media.ark
      @doi = media.doi

    end

    # this method is cloned from list_of_item_ids_to_display (for defaut view), 
    # and override the method in presenter_methods
    # to get a list of media images for MEDIA showpage
    def list_of_item_ids_to_display_for_showpage
      media_ids = []
      media_ids << @parent_media_id_list << @child_media_id_list << @sibling_media_id_list
      media_ids.flatten
    end

    def in_collection_badge
      # override the method in presents_attributes, passing the vouchered retrieved from get_showcase_data
      in_collection_badge_class.new(@vouchered).render
    end

    def supplied_record_badge
      # override the method in presents_attributes, passing the idigbio_uuid retrieved from get_showcase_data
      supplied_record_badge_class.new(@idigbio_uuid).render
    end

    # methods for showcase partials
    def showcase_work_title_partial
      'showcase_work_title'
    end

    def showcase_show_actions_partial
      'showcase_show_actions'
    end

    def showcase_file_object_details_partial
      'showcase_file_object_details'
    end

    def showcase_image_acquisition_partial
      'showcase_image_acquisition'
    end

    def showcase_image_acquisition_details_partial
      'showcase_image_acquisition_details'
    end

    def showcase_ownership_and_permissions_partial
      'showcase_ownership_and_permissions'
    end

    def showcase_identifiers_and_external_links_partial
      'showcase_identifiers_and_external_links'
    end

    def showcase_viewer_partial
      'showcase_viewer'
    end

    def showcase_media_items_partial
      'showcase_media_items'
    end

    def showcase_media_items_member_partial
      'showcase_media_items_member'
    end

    def showcase_collections_partial
      '/hyrax/physical_objects/showcase_collections'
    end

    def showcase_tags_partial
      '/hyrax/physical_objects/showcase_tags'
    end

    def showcase_citation_and_download_partial
      '/hyrax/physical_objects/showcase_citation_and_download'
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
