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


    def general_details_partial
      'showcase_general_details'
    end

    def taxonomy_partial
      'showcase_taxonomy'
    end

    def identifiers_and_external_links_partial
      'showcase_identifiers_and_external_links'
    end

    def time_and_place_details_partial
      '/hyrax/physical_objects/showcase_time_and_place_details'
    end

    def bibliographic_citations_partial
      '/hyrax/physical_objects/showcase_bibliographic_citations'
    end

    def media_partial
      '/hyrax/physical_objects/showcase_media'
    end

    def collections_partial
      '/hyrax/physical_objects/showcase_collections'
    end

    def tags_partial
      '/hyrax/physical_objects/showcase_tags'
    end

    def citation_and_download_partial
      '/hyrax/physical_objects/showcase_citation_and_download'
    end

  end
end
