module Morphosource
  module My
    class RequestManagersController < Hyrax::MyController

      include Morphosource::My::CartItemsBehavior

      def index
        get_items('request_manager')
        render 'morphosource/my/request_manager/index'
      end

      def approve_download
        items = get_items_by_id(params[:item_id] || params[:batch_document_ids])
        mark_as('approved',items)
        # temporary date expired
        mark_as('expired',items,Date.tomorrow)
        flash[:notice] = "#{count_text(items.count)} Approved for Download"
        redirect_to main_app.request_manager_path
      end

      def deny_download
        item = [CartItem.find(params[:item_id])]
        mark_as('denied',item)
        flash[:notice] = "Download Denied"
        redirect_to main_app.request_manager_path
      end

    end
  end
end
