module Morphosource
  # Adds methods to add work to parent work
  module FormMethods

    delegate :work_parents_attributes=, to: :model

    def self.included(base)
      base.extend(FormMethods)
    end

    # This code block is extending self.build_permitted_params from Hyrax::Forms::WorkForm
    # @return [Array] a list of parameters used by sanitize_params
    def build_permitted_params
      super + [
       :on_behalf_of,
       :version,
       :add_works_to_collection,
       {
         based_near_attributes: [:id, :_destroy],
         member_of_collections_attributes: [:id, :_destroy],
         work_members_attributes: [:id, :_destroy],
         work_parents_attributes: [:id, :_destroy]
       }
      ]
    end

    # @return [NilClass]
    def find_parent_work; end

    def member_of_works_json
      parent_works = model.in_works

      # If a work is deposited as a child of another work, it will have a parent_id
      if @controller.params[:parent_id]
        parent_works << ::ActiveFedora::Base.find(@controller.params[:parent_id])
      end

      parent_works.map do |parent|
        {
          id: parent.id,
          label: parent.to_s,
          path: @controller.url_for(parent)
        }
      end.to_json
    end

  end
end
