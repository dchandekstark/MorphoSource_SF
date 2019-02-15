module Morphosource
  module My
    class CartItemsController < Hyrax::MyController

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      before_action :get_curation_concern, only: [:create]

      def search_builder_class
        if cart?
          Morphosource::My::CartItems::CartItemsSearchBuilder
        else
          Morphosource::My::CartItems::DownloadsSearchBuilder
        end
      end

      def create
        unless item_already_in_cart?(params[:work_id])
          @item = CartItem.new({:media_cart_id => params[:media_cart_id], :work_id => params[:work_id]})
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

       def index
        @cart = cart?
        @items = current_user.cart_items
        super
        @count_text = count_text
        render 'index'
      end

      def destroy
        @item = CartItem.find(params[:id])
        if @item.destroy
          flash[:notice] = 'Item Removed from Cart'
        else
          flash[:alert] = 'Item Remove Unsuccessful'
        end
        redirect_to main_app.my_cart_path
      end

       private

        def cart?
          request.original_fullpath.include? '/dashboard/my/cart'
        end

        def works_in_cart
          current_user.work_ids_in_cart
        end

        def item_already_in_cart?(work)
          works_in_cart.include? work
        end

        def after_create_response(curation_concern)
          respond_to do |format|
            format.html { redirect_to [main_app, @curation_concern] }
            format.json { render work_to_render, status: :ok, location: polymorphic_path([main_app, @curation_concern]) }
          end
        end

        def get_curation_concern
          work_type = eval(params[:work_type])
          @curation_concern = work_type.find(params[:work_id]) unless @curation_concern
          work_to_render = (params[:work_type].downcase.concat('/show'))
        end

        def count_text
          @document_list.count.to_s.concat(@document_list.count == 1 ? " Item" : " Items")
        end

     end
  end
end
