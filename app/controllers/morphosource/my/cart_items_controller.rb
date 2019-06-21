module Morphosource
  module My
    class CartItemsController < Hyrax::MyController

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      before_action :get_curation_concern, only: [:create]

      # Used by Add to Cart button on Work show page
      def create
        unless work_already_in_cart?(params[:work_id])
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

      # Used when batch-copying previously downloaded items to cart
      def batch_create
        ids = params[:batch_document_ids]
        work_ids = ids.map{|id| CartItem.find(id).work_id}
        duplicate_work_ids = get_duplicate_works(work_ids, work_ids.uniq)
        count = ids.count - duplicate_work_ids.count
        duplicates = duplicate_work_ids.each_with_object([]) do |id, duplicates|
          duplicates << Media.find(id).title[0]
        end
        work_ids.uniq.each do |id|
          if work_already_in_cart?(id)
            duplicates << Media.find(id).title[0]
            count -= 1
          else
            @item = CartItem.new({:media_cart_id => current_user.media_cart.id, :work_id => id})
            @item.save!
          end
        end
        flash[:notice] = "#{count_text(count)} Added to Cart#{duplicates_text(duplicates)}"
        redirect_to main_app.my_cart_path
      end

      # Displays items in cart or previous downloads
      def index
        @item_count = item_count
        @items = items
        @solr_docs = solr_docs
        super
        render 'index'
      end

      def media_cart
        @cart = true
        self.index
      end

      def previous_downloads
        @cart = false
        self.index
      end

      def download
        if params[:batch_document_ids]
          item_ids = params[:batch_document_ids]
        else
          item_ids = current_user.item_ids_in_cart
        end
        items = item_ids.map{|id| CartItem.find(id)}
        work_ids = items.map{|item| item.work_id}
        mark_as_downloaded(items)
        redirect_to main_app.zip_hyrax_media_index_path(ids: work_ids)
      end

      # Used when batch removing items from the media cart
      # For selecting multiple items, uses batch_document_ids param
      # Clear Cart button uses current_user's items in cart
      def batch_destroy
        if params[:batch_document_ids]
          all_items = params[:batch_document_ids].map{|id| CartItem.find(id)}
        else
          all_items = items_in_cart
        end
        count = all_items.count
        downloaded_items = all_items.select{|item| item.date_downloaded.present?}
        items = all_items - downloaded_items
        if items.each(&:destroy)
          flash[:notice] = "#{count_text(count)} Removed from Cart"
          downloaded_items.each do |item|
            item.in_cart = false
            item.save!
          end
        else
          flash[:alert] = 'Not Able to Remove Items'
        end
        redirect_to main_app.my_cart_path
      end

      private

        def file_restricted?(accessibility)
          params[:file_accessibility] == "restricted_download"
        end

        def works_in_cart
          current_user.work_ids_in_cart
        end

        def item_ids_in_cart
          current_user.item_ids_in_cart
        end

        def items_in_cart
          current_user.items_in_cart
        end

        def downloaded_works
          current_user.downloaded_work_ids
        end

        def downloaded_items
          current_user.downloaded_item_ids
        end

        def work_already_in_cart?(work)
          works_in_cart.include? work
        end

        # Displays items by date descending
        def items
          ids = @cart ? item_ids_in_cart : downloaded_items
          order = @cart ? 'created_at DESC' : 'date_downloaded DESC'
          CartItem.where(id: ids).order(order).page params[:page]
        end

        def item_count
          count = @cart ? item_ids_in_cart.count : downloaded_items.count
          count_text(count)
        end

        def count_text(count)
          @item_count = count.to_s.concat(count == 1 ? " Item" : " Items")
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
        def solr_docs
          ids = @cart ? works_in_cart : downloaded_works.uniq
          ids.each_with_object([]){|id, docs| docs << SolrDocument.find(id)}
        end

        # Get duplicates if a user tries to send them to the media cart
        def get_duplicate_works(works, uniq_works)
          works = works.dup
          uniq_works.each {|id| works.slice!(works.index(id)) if works.include?(id) }
          works
        end

        def mark_as_downloaded(items)
          items.each do |item|
            item.date_downloaded = Time.current
            item.save!
          end
        end
     end
  end
end
