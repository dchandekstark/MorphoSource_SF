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
          work_ids: :work_ids_in_cart,
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
          item_ids: :newly_requested_item_ids,
          order: 'date_requested DESC',
          work_ids: :newly_requested_items_work_ids
        },
        'previous_requests' => {
          item_ids: :previously_requested_item_ids,
          order: 'date_requested DESC',
          work_ids: :previously_requested_items_work_ids
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

      def item_count_text
        count_text(@items.count)
      end

      def id_params
        params[:item_id] || params[:batch_document_ids]
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

      def work_already_in_cart?(id)
        work_ids_in_cart.include? id
      end

      def mark_as(action,items=@items,date: nil)
        date = attribute_value(date)
        attribute = get_attribute(action)
         items.each do |item|
          item.date_cleared = nil if item.date_cleared
          item.send(attribute, date)
          item.save
        end
      end

      def get_attribute(action)
        return 'in_cart=' if action == 'in_cart'
        'date_'.concat(action).concat('=')
      end

      def attribute_value(date)
        case date
        when nil
          Time.now
        when 'nil'
          nil
        else
          date
        end
      end

      def re_request(items)
        mark_as('in_cart',items,date: false)
        create_new_items(items)
      end

      def requested(items)
        items.select{|item| item.date_requested }
      end

      def unrequested(items)
        items.select{|item| !item.date_requested }
      end

      def get_items_by_id(ids=id_params)
        @items = CartItem.where(id: ids)
      end

      def get_media_by_items(items)
        get_work_ids_by_items(items)
        Media.where(id: @work_ids)
      end

      def get_work_ids_by_items(items=@items)
        @work_ids = items.map{|item| item.work_id}
      end

      def create_new_items(old_items,requested='requested')
        value = requested == 'requested' ? Time.now : nil
        works = get_media_by_items(old_items)
        @count = 0
        @duplicates_in_cart = []
        works.each do |work|
          unless work_already_in_cart?(work.id)
            item = CartItem.new({media_cart_id: current_user.media_cart.id, work_id: work.id, in_cart: true, approver: work.depositor, date_requested: value, restricted: work.restricted?})
            item.save
            @count += 1
          else
            @duplicates_in_cart << work.title[0]
          end
        end
        return @count, @duplicates_in_cart
      end

      def uniq_downloaded_work_ids
        downloaded_work_ids.uniq
      end

      def unrestricted_items
        items_in_cart.select{ |item| item.downloadable? }
      end

      def restricted_items
        items_in_cart.select{ |item| !item.downloadable? }
      end

      def user_is_depositor?(work)
        current_user.email == work.depositor
      end

      def user_is_approver?(item)
        current_user.email == item.approver
      end

      def unrestrict(item)
        item.restricted = false
        item.save
      end

      delegate :downloaded_work_ids, :downloaded_items, :items_in_cart, :item_ids_in_cart, :my_requests_ids, :my_requests_work_ids, :requested_items, :previously_requested_items, :newly_requested_items, :requested_item_ids, :previously_requested_item_ids, :newly_requested_item_ids, :requested_items_work_ids, :previously_requested_items_work_ids, :newly_requested_items_work_ids, :work_ids_in_cart, to: :current_user
    end
  end
end
