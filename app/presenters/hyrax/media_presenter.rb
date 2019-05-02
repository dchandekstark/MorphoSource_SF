require 'active_support/core_ext/numeric/conversions'
# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  class MediaPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :agreement_uri, :cite_as, :funding, :map_type, :media_type, :modality, :orientation, :part, :rights_holder, :scale_bar, :series_type, :side, :unit, :x_spacing, :y_spacing, :z_spacing, :slice_thickness, :identifier, :related_url, :point_count, to: :solr_document

    attr_accessor :physical_object_type, :idigbio_uuid, :vouchered, 
      :physical_object_title, :physical_object_link, :physical_object_id, 
      :device_and_facility, :device_facility, :device_link, :device, 
      :other_details, :imaging_event_creator, :imaging_event_date_created, 
      :parent_media_id_list, :child_media_id_list, 
      :sibling_media_id_list, :parent_media_count, :direct_parent_members, :this_media_member,
      :processing_event_count, :data_managed_by, :download_permission, :ark, :doi, :lens, 
      :raw_or_derived,
      :imaging_event_exist,
      :p_physical_object_title, :p_physical_object_link, :p_physical_object_id, 
      :p_device_and_facility, :p_device_facility, :p_device_link, :p_device, 
      :p_other_details, :p_imaging_event_creator, :p_imaging_event_date_created, :p_modality,
      :p_raw_or_derived,
      :file_size, :point_count, :face_count

    def universal_viewer?
      representative_id.present? &&
        representative_presenter.present? &&
        (representative_presenter.image? || representative_presenter.mesh?) &&
        Hyrax.config.iiif_image_server? &&
        (members_include_viewable_image? || members_include_viewable_mesh?)
    end

    def get_showcase_data
      media = Media.where('id' => solr_document.id).first

      # should not need parent titles any more.  remove later
      #@direct_parent_title_list = []
      #@direct_parent_id_list.each do |parent_id|
      #  parent_media = Media.where('id' => parent_id).first
      #  @direct_parent_title_list << parent_media.title.first
      #end
      #@direct_parent_title_list = @direct_parent_title_list.join(', ')

      # todo: need to get the user name (and a link to user) from the email address
      @data_managed_by = solr_document.depositor
      
      if media.fileset_visibility.include? 'restricted'
        @download_permission = 'restricted'
      else
        @download_permission = 'open'
      end

      @ark = media.ark
      @doi = media.doi

      # get file characterization metadata, and add up the values (face count, point count, file size, etc)
      @file_size = 0
      @point_count = 0
      @face_count = 0
      file_set_list = media.file_set_ids
      file_set_list.each do |id|
        file_set = ::FileSet.find(id)
        @file_size += file_set.file_size.first.to_i if file_set.file_size.present?
        @point_count += file_set.point_count.first.to_i if file_set.point_count.present? 
        @face_count += file_set.face_count.first.to_i  if file_set.face_count.present?
      end
      if @file_size == 0
        @file_size = ""
      else
        @file_size = @file_size.to_s(:delimited) + " bytes" # todo: convert to pretty format later
      end
      if @point_count == 0
        @point_count = ""
      else
        @point_count = @point_count.to_s(:delimited) 
      end
      if @face_count == 0
        @face_count = ""
      else
        @face_count = @face_count.to_s(:delimited) 
      end


      # Get parent medias    
      # add current media id, then add child media ids.  
      # currently add up to 5 levels in the tree.  Later we should store the child medias in the work
      # so there is no need to traverse the tree
      @parent_media_id_list = parent_media_ids(media, 5, []).flatten.uniq
      @parent_media_count = @parent_media_id_list.length.to_s
      @child_media_id_list = child_media_ids(media, 5, []).flatten.uniq
      @sibling_media_id_list = sibling_media_ids(media, []).flatten.uniq

      # get the  parents
      direct_parent_id_list = parent_media_ids(media, 1, []).flatten.uniq
      @direct_parent_members = member_presenters_for(direct_parent_id_list)
      this_media_list = [] << solr_document.id 
      @this_media_member = member_presenters_for(this_media_list).first 


      @raw_or_derived = "Raw"
      @p_raw_or_derived = "Raw"
      if direct_parent_id_list.length > 0
        # If a media has a parent work and is derived, then that media’s raw ancestor media work 
        # (whether parent, grandparent, etc) should be connected to an IE from which metadata should be derived.
        @raw_or_derived = "Derived"
        direct_parent_id = direct_parent_id_list.first
        
        target_media = Media.where('id' => direct_parent_id).first
      else
        # If a media is raw and has no parent media work, then get data from current media via the IE.
        target_media = media
      end

      # Get the physical object type from:
      # Media < ImagingEvent < BiologicalSpecimen (or CulturalHeritageObject)
      imaging_event = ImagingEvent.where('member_ids_ssim' => target_media.id).first
      if imaging_event.present?
        imaging_event_exist = true
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
          @device = device.title.first
          @device_facility = device.facility.first
          @device_and_facility = @device
          @device_and_facility += " (" + @device_facility + ")" if @device_facility.present?
          @device_link = "/concern/devices/" + device.id
        end

        # get imaging event details
        @lens = ""
        @lens << imaging_event.lens_make.first if imaging_event.lens_make.present?
        @lens << " " + imaging_event.lens_model.first if imaging_event.lens_model.present?
        @other_details = []
        @other_details << imaging_event.focal_length_type.first + " focal length" if imaging_event.focal_length_type.present?
        @other_details << imaging_event.light_source.first + " light" if imaging_event.light_source.present?
        @other_details << imaging_event.background_removal.first if imaging_event.background_removal.present?
        @other_details = @other_details.join(' / ')
        @imaging_event_creator = imaging_event.creator
        @imaging_event_date_created = imaging_event.date_created

      else
        imaging_event_exist = false
      end # end if imaging_event present?
 



      # get processing event:  media < processing_event
      processing_events = ProcessingEvent.where('member_ids_ssim' => solr_document.id)
      if processing_events.present?
        @processing_event_count = processing_events.count 
      else
        @processing_event_count = 0
      end


      # get physical object and other metadata of parent
      # Parent Media < ImagingEvent < BiologicalSpecimen (or CulturalHeritageObject)
      # todo: later on we will need to handle more than 1 parent
      #@direct_parent_id_list.each do |parent_id|
      #  parent_media = Media.where('id' => parent_id).first
      #end
      @raw_or_derived = "Raw"
      @p_raw_or_derived = "Raw"
      if direct_parent_id_list.length > 0
        @raw_or_derived = "Derived"
        direct_parent_id = direct_parent_id_list.first
        
        p_media = Media.where('id' => direct_parent_id).first
        @p_modality = p_media.modality.first
        p_direct_parent_id_list = parent_media_ids(p_media, 1, []).flatten.uniq
        if p_direct_parent_id_list.length > 0
          @p_raw_or_derived = "Derived"
        end

        p_imaging_event = ImagingEvent.where('member_ids_ssim' => direct_parent_id).first
        if p_imaging_event.present?
          p_biological_specimen = BiologicalSpecimen.where('member_ids_ssim' => p_imaging_event.id).first
          p_cultural_heritage_object = CulturalHeritageObject.where('member_ids_ssim' => p_imaging_event.id).first

          if p_biological_specimen.present?
            @p_physical_object_title = p_biological_specimen.title.first
            @p_physical_object_id = p_biological_specimen.id
            @p_physical_object_link = "/concern/biological_specimens/" + @p_physical_object_id
          elsif p_cultural_heritage_object.present?
            @p_physical_object_title = p_cultural_heritage_object.title.first
            @p_physical_object_id = p_cultural_heritage_object.id
            @p_physical_object_link = "/concern/cultural_heritage_object/" + @p_physical_object_id
          end

          # get device from imaging event for parent media
          p_device = Device.where('member_ids_ssim' => p_imaging_event.id).first
          if p_device.present?
            @p_device = p_device.title.first
            @p_device_facility = p_device.facility.first
            @p_device_and_facility = @p_device
            @p_device_and_facility += " (" + @p_device_facility + ")" if @p_device_facility.present?
            @p_device_link = "/concern/devices/" + p_device.id
          end

          # get imaging event details for parent media
          @p_lens = ""
          @p_lens << p_imaging_event.lens_make.first if p_imaging_event.lens_make.present?
          @p_lens << " " + p_imaging_event.lens_model.first if p_imaging_event.lens_model.present?
          @p_other_details = []
          @p_other_details << p_imaging_event.focal_length_type.first + " focal length" if p_imaging_event.focal_length_type.present?
          @p_other_details << p_imaging_event.light_source.first + " light" if p_imaging_event.light_source.present?
          @p_other_details << p_imaging_event.background_removal.first if p_imaging_event.background_removal.present?
          @p_other_details = @p_other_details.join(' / ')
          @p_imaging_event_creator = p_imaging_event.creator
          @p_imaging_event_date_created = p_imaging_event.date_created




        end

      end

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

    def showcase_direct_parents_member_partial
      'showcase_direct_parents_member'
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
