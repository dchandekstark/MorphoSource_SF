module Morphosource
  module My
    module CartItemsBehavior

      def get_items(page)
        @items = items(page)
        @solr_docs = solr_docs(page)
        @item_count = item_count(page)
      end

      def get_restricted_items
        @unrestricted_items = unrestricted_items
        @restricted_items = restricted_items
        @restricted_count = count_text(@restricted_items.count)
      end

      @@page_items = {
        'cart' => {
          item_ids: :item_ids_in_cart,
          order: 'created_at DESC',
          work_ids: :works_in_cart,
        },
        'downloads' => {
          item_ids: :downloaded_items,
          order: 'date_downloaded DESC',
          work_ids: :uniq_downloaded_work_ids
        },
        'my_requests' => {
          item_ids: :my_requests_ids,
          order: 'created_at DESC',
          work_ids: :my_requests_work_ids
        },
        'request_manager' => {
          item_ids: :requested_item_ids,
          order: 'date_requested DESC',
          work_ids: :requested_items_work_ids
        }
      }

      def file_restricted?(accessibility)
        accessibility == "restricted_download"
      end

      def items(page)
        ids = get_value(page,:item_ids)
        order = get_order(page)
        CartItem.where(id: ids).order(order).page params[:page]
      end

      def get_value(page,key)
        self.method(@@page_items[page][key]).()
      end

      def get_order(page)
        @@page_items[page][:order]
      end

      def item_count(page)
        count = get_value(page,:item_ids).count
        count_text(count)
      end

      def count_text(count)
        count.to_s.concat(count == 1 ? " Item" : " Items")
      end

      def duplicates_text(duplicates)
        if duplicates.count > 0
          "; #{count_text(duplicates.count)}: #{duplicates.join(', ')} Already in Your Cart."
        else
          ''
        end
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

      # Using instead of search in order to get back full results instead of paginated
      def solr_docs(page)
        work_ids = get_value(page,:work_ids)
        work_ids.each_with_object([]){|id, docs| docs << SolrDocument.find(id)}
      end

      # Get duplicates if a user tries to send them to the media cart
      def get_duplicate_works(works, uniq_works)
        works = works.dup
        uniq_works.each {|id| works.slice!(works.index(id)) if works.include?(id) }
        works
      end

      def work_already_in_cart?(work)
        works_in_cart.include? work
      end

      def mark_as(action,items,value=nil)
        attribute = get_attribute(action)
        value = Time.now if value == nil
        items.each do |item|
          item.send(attribute, value)
          item.save
        end
      end

      def get_attribute(action)
        return 'in_cart=' if action == 'in_cart'
        'date_'.concat(action).concat('=')
      end

      def get_items_by_id(ids)
        CartItem.where(id: ids)
      end

      def get_media_by_items(items)
        work_ids = get_work_ids_by_items(items)
        Media.where(id: work_ids)
      end

      def get_work_ids_by_items(items)
        items.map{|item| item.work_id}
      end

      def create_new_items(old_items)
        works = get_media_by_items(old_items)
        works.each do |work|
          unless work_already_in_cart?(work.id)
            item = CartItem.new({media_cart_id: current_user.media_cart.id, work_id: work.id, in_cart: true, approver: work.depositor, date_requested: Time.now, restricted: work.restricted?})
            item.save
          end
        end
      end

      def downloaded_work_ids
        current_user.downloaded_work_ids
      end

      def uniq_downloaded_work_ids
        downloaded_work_ids.uniq
      end

      def downloaded_items
        current_user.downloaded_item_ids
      end

      def items_in_cart
        current_user.items_in_cart
      end

      def item_ids_in_cart
        current_user.item_ids_in_cart
      end

      def my_requests_ids
        current_user.my_requests_ids
      end

      def my_requests_work_ids
        current_user.my_requests_work_ids
      end

      def requested_items
        current_user.requested_items
      end

      def requested_item_ids
        current_user.requested_item_ids
      end

      def requested_items_work_ids
        current_user.requested_items_work_ids
      end

      def restricted_items
        items_in_cart.select{ |item| !item.downloadable? }
      end

      def unrestricted_items
        items_in_cart.select{ |item| item.downloadable? }
      end

      def works_in_cart
        current_user.work_ids_in_cart
      end

    end
  end
end
