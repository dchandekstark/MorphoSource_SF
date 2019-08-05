module Morphosource
  module My
    class RequestsController < Hyrax::MyController

      include Morphosource::My::CartItemsBehavior

      def index
        get_items('my_requests')
        render 'morphosource/my/requests/index'
      end

      def request_item
        items = get_items_by_id( params[:item_id] || params[:batch_document_ids] )
        requested_items = requested(items)
        unrequested_items = unrequested(items)
        mark_as('requested',unrequested_items)
        re_request(requested_items)
        flash[:notice] = count_text(items.count).concat(' Requested')
        redirect_back(fallback_location: my_requests_path)
      end

      def request_again
        item_ids = ( params[:item_id] || params[:batch_document_ids] )
        items = get_items_by_id(item_ids)
        re_request(items)
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
