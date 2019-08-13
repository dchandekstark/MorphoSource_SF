module Morphosource
  module My
    class RequestsController < Hyrax::MyController

      include Morphosource::My::CartItemsBehavior

      before_action :get_items_by_id, except: [:index]

      def index
        get_items('my_requests')
        render 'morphosource/my/requests/index'
      end

      def request_item
        re_request(requested(@items))
        mark_as('requested',unrequested(@items))
        flash[:notice] = item_count_text.concat(' Requested')
        redirect_back(fallback_location: my_requests_path)
      end

      def request_again
        re_request(@items)
        redirect_back(fallback_location: my_requests_path)
      end

      def cancel_request
        mark_as('canceled')
        flash[:notice] = "Request Canceled"
        redirect_back(fallback_location: my_requests_path)
      end

      def move_to_cart
        mark_as('in_cart',date: true)
        flash[:notice] = "Item Moved to Cart"
        redirect_back(fallback_location: my_requests_path)
      end

    end
  end
end
