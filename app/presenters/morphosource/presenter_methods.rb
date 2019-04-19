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
      # BiologicalSpecimen > ImagingEvent > Media 
      child_ids = solr_document.member_ids  # todo: do we need to handle more than one imaging event?
      imaging_event = ImagingEvent.where('id' => child_ids).first
      media_ids = []

      if imaging_event.present?
        child_ids = imaging_event.member_ids  # todo: do we need to handle more than one media work?
        media = Media.where('id' => child_ids).first
        if media.present?
          # add current media file sets, then add child media file sets.  
          # currently add up to 5 levels in the tree.  Later we should store the child medias in the work
          # so there is no need to traverse the tree
          media_ids << media.id
          media_ids << child_media_ids(media, 5, media_ids)
        end
      end
      media_ids.flatten.uniq 
    end

    # this method recursively traverse the tree up to X level to gather all ids of child medias
    def child_media_ids(media, level, media_ids)
      if level == 0
        return []
      else
        child_medias = child_medias(media)
        child_medias.each do |child_media|
          media_ids << child_media.id
          level = level - 1
          media_ids << child_media_ids(child_media, level, media_ids)
        end
        media_ids.flatten.uniq # remove any duplicate IDs before returning
      end
    end

    # this method get a list of child media of a passed media 
    def child_medias(media)
      child_medias = []
      processing_event = nil
      child_media = nil
      # Find child media: Media > ProcessingEvent > Media
      media.member_ids.each do |id|
        if ProcessingEvent.where('id' => id).present? # todo: do we need to handle more than one processing event?
          processing_event = ProcessingEvent.where('id' => id).first
        end
      end
      if processing_event.present?
        child_ids = processing_event.member_ids
        child_ids.each do |id|
          if Media.where('id' => id).present?
            child_media = Media.where('id' => id).first
            child_medias << child_media
          end
        end
      end
      child_medias
    end

    # this method recursively traverse the tree up to X level to gather all ids of parent medias
    def parent_media_ids(media, level, media_ids)
      if level == 0
        return []
      else
        parent_medias = parent_medias(media)
        parent_medias.each do |parent_media|
          media_ids << parent_media.id
          level = level - 1
          media_ids << parent_media_ids(parent_media, level, media_ids)
        end
        media_ids.flatten.uniq # remove any duplicate IDs before returning
      end
    end

    # this method get a list of parent media of a passed media 
    def parent_medias(media)
      parent_medias = []
      # Find parent media: Media < ProcessingEvent < Media    
      processing_events = ProcessingEvent.where('member_ids_ssim' => media.id)
      if processing_events.present?
        processing_events.each do |processing_event|
          medias = Media.where('member_ids_ssim' => processing_event.id)
          if medias.present?
            parent_medias += medias
          end
        end              
      end
      parent_medias
    end

  end
end
