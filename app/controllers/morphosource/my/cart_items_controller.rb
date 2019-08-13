module Morphosource
  module My
    class CartItemsController < Hyrax::MyController

      include Morphosource::My::CartItemsBehavior

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      before_action :get_curation_concern, only: [:create]

      # Used by Add to Cart button on Work show page
      def create
        work = @curation_concern
        unless work_already_in_cart?(work.id)
          item = create_item(params,work)
          if item.restricted? && user_is_approver?(item)
            unrestrict(item)
          end
          flash[:notice] = 'Item Added to Cart'
        else
          flash[:alert] = 'Item Already in Cart'
        end
        after_create_response(work)
      end

      private

        def create_item(params,work)
          CartItem.create({:media_cart_id => params[:media_cart_id], :work_id => work.id, :restricted => work.restricted?})
        end

    end
  end
end
