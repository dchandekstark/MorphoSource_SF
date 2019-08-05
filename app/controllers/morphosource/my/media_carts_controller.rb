module Morphosource
  module My
    class MediaCartsController < Hyrax::MyController
      helper CartItemHelper
      include Morphosource::My::CartItemsBehavior

      def index
        get_items('cart')
        get_restricted_items
        render 'morphosource/my/cart/index'
      end

      def download
        get_downloadable_items
        mark_as('downloaded')
        get_work_ids_by_items
        redirect_to main_app.zip_hyrax_media_index_path(ids: @work_ids)
      end

      def destroy
        get_items_by_id(id_params || item_ids_in_cart)
        flash[:notice] = destroy_flash
        remove_from_cart
        redirect_back(fallback_location: my_cart_path)
      end

      private

      def get_downloadable_items
        @items = id_params ? get_items_by_id(id_params) & unrestricted_items : unrestricted_items
      end

      def destroy_flash
        "#{item_count_text} Removed from Cart"
      end

      def remove_from_cart
        @items.each do |item|
          if (item.date_downloaded? || item.date_requested?)
            item.in_cart = false
            item.save
          else
            item.destroy
          end
        end
      end

    end
  end
end
