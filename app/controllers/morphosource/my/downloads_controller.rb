module Morphosource
  module My
    class DownloadsController < Hyrax::MyController

      include Morphosource::My::CartItemsBehavior

      def index
        get_items('downloads')
        render 'morphosource/my/downloads/index'
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
            work = Media.find(id)
            @item = CartItem.new({:media_cart_id => current_user.media_cart.id, :work_id => id, :restricted => work.restricted?, :approver => work.depositor})
            @item.save!
          end
        end
        flash[:notice] = "#{count_text(count)} Added to Cart#{duplicates_text(duplicates)}"
        redirect_to main_app.my_cart_path
      end

    end
  end
end
