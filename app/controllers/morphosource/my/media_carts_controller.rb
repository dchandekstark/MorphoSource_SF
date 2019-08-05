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
        if (params[:batch_document_ids] || params[:item_id])
          item_ids = params[:batch_document_ids] || [params[:item_id]]
          items = get_items_by_id(item_ids) & unrestricted_items
        else
          items = unrestricted_items
        end
        work_ids = get_work_ids_by_items(items)
        mark_as('downloaded',items)
        redirect_to main_app.zip_hyrax_media_index_path(ids: work_ids)
      end

      def destroy
        items = get_items_by_id( params[:item_id] || params[:batch_document_ids] || item_ids_in_cart)
        count = items.count.dup
        items.each do |item|
          if (item.date_downloaded? || item.date_requested?)
            item.in_cart = false
            item.save
          else
            item.destroy
          end
        end
        flash[:notice] = "#{count_text(count)} Removed from Cart"
        redirect_back(fallback_location: my_cart_path)
      end

    end
  end
end
