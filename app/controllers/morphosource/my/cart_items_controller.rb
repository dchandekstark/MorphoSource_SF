module Morphosource
  module My
    class CartItemsController < Hyrax::MyController

      include Morphosource::My::CartItemsBehavior

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      before_action :get_curation_concern, only: [:create]

      # Used by Add to Cart button on Work show page
      def create
        unless work_already_in_cart?(params[:work_id])
          @item = CartItem.new({:media_cart_id => params[:media_cart_id], :work_id => params[:work_id], :restricted => file_restricted?(params[:file_accessibility])})
          if @item.save!
            flash[:notice] = 'Item Added to Cart'
          else
            flash[:alert] = 'Item Add Unsuccessful'
          end
        else
          flash[:alert] = 'Item Already in Cart'
        end
        after_create_response(@curation_concern)
      end
    end
  end
end
