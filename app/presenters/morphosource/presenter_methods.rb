module Morphosource
  module PresenterMethods

    # Methods below used to parent works on a work's show page.

    def work
      ::ActiveFedora::Base.find(solr_document.id)
    end

    # Methods below copied from rdr/dataset_presenter.rb
    # Adds "In Media, In Physical object," etc. to Relationships section of a work's show page.

    # Overrides 'Hyrax::WorkShowPresenter#grouped_presenters' to add in the presenters for works in which the current
    # work is nested
    def grouped_presenters(filtered_by: nil, except: nil)
      super.merge(grouped_work_presenters(filtered_by: filtered_by, except: except))
    end

    # modeled on '#grouped_presenters' in Hyrax::WorkShowPresenter, which returns presenters for the collections of
    # which the work is a member
    def grouped_work_presenters(filtered_by: nil, except: nil)
      grouped = in_work_presenters.group_by(&:model_name).transform_keys { |key| key.to_s.underscore }
      grouped.select! { |obj| obj.downcase == filtered_by } unless filtered_by.nil?
      grouped.except!(*except) unless except.nil?
      grouped || {}
    end

    # modeled on '#member_of_collection_presenters' in Hyrax::WorkShowPresenter
    def in_work_presenters
      Hyrax::PresenterFactory.build_for(ids: work.in_works_ids,
                                 presenter_class: Hyrax::WorkShowPresenter,
                                 presenter_args: presenter_factory_arguments)
    end

    # media cart method
    def works_in_cart
      current_ability.current_user.work_ids_in_cart
    end

    def downloaded_works
      current_ability.current_user.downloaded_work_ids 
    end

    # physical objects showcase page methods
    def parent_institution_title
      title = Institution.where('member_ids_ssim' => solr_document.id).first.title.first
      if title.nil?
        title = ''
      end
      title
    end

    def parent_institution_code
      code = Institution.where('member_ids_ssim' => solr_document.id).first.institution_code.first
      if code.nil?
        code = ''
      end
      code
    end

    def source_of_record
      if solr_document.idigbio_uuid.present?
        'iDigBio'
      else
        ''
      end
    end
    
    # this method is cloned from list_of_item_ids_to_display (for defaut view), 
    # to get a list of media images for PO showpage
    def list_of_item_ids_to_display_for_showpage
      # get the media from
      # BiologicalSpecimen > ImagingEvent > Media > File set
      child_ids = solr_document.member_ids  # todo: do we need to handle more than one imaging event?
      imaging_event = ImagingEvent.where('id' => child_ids).first
      media_file_set_ids = []

      if imaging_event.present?
        child_ids = imaging_event.member_ids  # todo: do we need to handle more than one media work?
        media = Media.where('id' => child_ids).first
        if media.present?
          # add current media file sets, then add child media file sets.  
          # currently add up to 9 levels in the tree.  Later we should store the child medias in the work
          # so there is no need to traverse the tree
          media_file_set_ids = media.file_set_ids
          media_file_set_ids += child_media_file_set_ids(media, 9, media_file_set_ids)
        end
      end

      media_file_set_ids.uniq # remove any duplicate IDs before returning
    end

    # this method recursively traverse the tree up to X level to gather all file set ids of child medias
    def child_media_file_set_ids(media, level, media_file_set_ids)
      if level == 0
        return []
      else
        child_medias = child_medias(media)
        child_medias.each do |child_media|

          media_file_set_ids += child_media.file_set_ids
          level = level - 1
          media_file_set_ids += child_media_file_set_ids(child_media, level, media_file_set_ids)

        end
        media_file_set_ids
      end
    end

    # this method get a list of child media of a passed media 
    def child_medias(media)
      child_medias = []
      temp = nil

      # Find child media: Media > ProcessingEvent > Media
      media.member_ids.each do |id|
        if ProcessingEvent.where('id' => id).present? # todo: do we need to handle more than one processing event?
          temp = ProcessingEvent.where('id' => id).first
        end
      end
      if temp.present?
        processing_event = temp
        child_ids = processing_event.member_ids
        child_ids.each do |id|
          if Media.where('id' => id).present?
            child_medias += Media.where('id' => id)
          end
        end
      end

      child_medias
    end


    # methods for showcase partials
    def showcase_work_title_partial
      'showcase_work_title'
    end

    def showcase_show_actions_partial
      '/hyrax/physical_objects/showcase_show_actions'
    end

    def showcase_preview_image_partial
      'showcase_preview_image'
    end

    def showcase_general_details_partial
      'showcase_general_details'
    end

    def showcase_taxonomy_partial
      'showcase_taxonomy'
    end

    def showcase_identifiers_and_external_links_partial
      'showcase_identifiers_and_external_links'
    end

    def showcase_time_and_place_details_partial
      '/hyrax/physical_objects/showcase_time_and_place_details'
    end

    def showcase_bibliographic_citations_partial
      '/hyrax/physical_objects/showcase_bibliographic_citations'
    end

    def showcase_media_items_partial
      '/hyrax/physical_objects/showcase_media_items'
    end

    def showcase_media_items_member_partial
      '/hyrax/physical_objects/showcase_media_items_member'
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

  end
end
