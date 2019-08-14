module Morphosource
  module My
    class CartItemsController < Hyrax::MyController

      include Morphosource::My::CartItemsBehavior

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      before_action :get_curation_concern, only: [:create]

      # Used by Add to Cart button on Work showcase page
      def create
        work = @curation_concern
        unless work_already_in_cart?(work.id)
          if work_requested?(work.id)
            item = find_requested_item(work.id)
            mark_as('in_cart',item,date: true)
          else
            item = create_cart_item(work.id)
            if item.restricted? && user_is_approver?(item)
              unrestrict(item)
            end
          end
          flash[:notice] = 'Item Added to Cart'
        else
          flash[:alert] = 'Item Already in Cart or Requested'
        end
        after_create_response(work)
      end

    end
  end
end
