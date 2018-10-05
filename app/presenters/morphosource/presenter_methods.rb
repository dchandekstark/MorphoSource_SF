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
                                 presenter_class: work_presenter_class,
                                 presenter_args: presenter_factory_arguments)
    end

  end
end
