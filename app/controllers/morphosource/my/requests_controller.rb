module Morphosource
  module My
    class RequestsController < Hyrax::MyController

      include Morphosource::My::CartItemsBehavior

      def index
        get_items('my_requests')
        render 'morphosource/my/requests/index'
      end

      # TODO - prevent previously requested items from being requested, send to request_again
      def request_item
        items = get_items_by_id( params[:item_id] || params[:batch_document_ids] )
        mark_as('requested',items)
        flash[:notice] = count_text(items.count).concat(' Requested')
        redirect_back(fallback_location: my_requests_path)
      end

      def request_again
        old_item_ids = ( params[:item_id] || params[:batch_document_ids] )
        old_items = get_items_by_id(old_item_ids)
        mark_as('in_cart',old_items,false)
        create_new_items(old_items)
        redirect_back(fallback_location: my_requests_path)
      end

      def cancel_request
        item = get_items_by_id(params[:item_id])
        mark_as('canceled',item)
        flash[:notice] = "Request Canceled"
        redirect_back(fallback_location: my_requests_path)
      end

    end
  end
end
