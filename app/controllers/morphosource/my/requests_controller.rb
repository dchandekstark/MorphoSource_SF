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
        re_request(inactive(@items))
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

      # Request download from media showcase page
      def request_work
        work_id = params[:work_id]
        if work_already_in_cart?(work_id)
          item = find_item_in_cart(work_id)
          if item_is_unrequested?(item)
            mark_as('requested',item)
          else
            re_request(item)
          end
        else
          create_new_requested_item(work_id)
        end
        redirect_back(fallback_location: my_requests_path)
      end

      private

        def item_is_unrequested?(item)
          item.date_requested == nil
        end

        def find_item_in_cart(work_id)
          current_user.items_in_cart.find{ |i| i.work_id == work_id }
        end

        def create_new_requested_item(work_id)
          item = create_cart_item(work_id)
          mark_as('requested',item)
          mark_as('in_cart',item,date: true)
        end

    end
  end
end
