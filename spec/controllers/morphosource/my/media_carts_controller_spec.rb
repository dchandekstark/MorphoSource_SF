require 'rails_helper'
require 'iiif_manifest'

include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::MediaCartsController, :type => :controller  do

  include_context 'cart items'

  describe "GET #index" do

    before do
      get :index
    end

    include_examples '#index'
    include_examples '#get_items instance variables', 'media cart'

    it 'retrieves a formatted count of restricted items in the cart' do
      expect(subject.instance_variable_get(:@restricted_count)).to eq('1 Item')
    end

    it 'retrieves restricted items in the cart' do
      expect(subject.instance_variable_get(:@restricted_items)).to match_array([cartItem3])
    end

    it 'retrieves unrestricted items in the cart' do
      expect(subject.instance_variable_get(:@unrestricted_items)).to match_array([cartItem1,cartItem2])
    end

    it 'does not retrieve restricted items not in the cart' do
      expect(subject.instance_variable_get(:@restricted_items)).not_to include(cartItem5)
    end

    it 'does not retrieve unrestricted items not in the cart' do
      expect(subject.instance_variable_get(:@unrestricted_items)).not_to include(cartItem4,cartItem6)
    end
  end


  describe 'GET #download' do

    context 'the user uses the item download button to
    download one item' do

      context 'the item is unrestricted' do
        before do
          get :download, params: {item_id: cartItem2.id}
        end

        it "marks the item downloaded" do
          cartItem2.reload
          expect(cartItem2.date_downloaded.to_date).to eq(Time.now.to_date)
        end

        it "does not change the date downloaded for unselected items in the cart" do
          cartItem3.reload
          expect(cartItem3.date_downloaded).to be(nil)
        end

        it "redirects to media/#zip with the work id as params" do
          work_id = cartItem2.work_id
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/concern/media/zip?)
          expect(redirect_params["ids[]"]).to eq(work_id)
        end

      end
      context 'the item is restricted' do
        before do
          get :download, params: {item_id: cartItem3.id}
        end

        it "does not mark the item downloaded" do
          cartItem3.reload
          expect(cartItem3.date_downloaded).to be(nil)
        end

        it "does not change the date downloaded for unselected items in the cart" do
          cartItem1.reload
          expect(cartItem1.date_downloaded.to_date).to eq(Date.yesterday)
        end

        it "redirects to media/#zip with nil as params" do
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/concern/media/zip?)
          expect(redirect_params["ids[]"]).to be(nil)
        end
      end
    end

    context 'the user batch-selects items to download' do
      context 'the selected items are unrestricted' do
        before do
          get :download, params: { batch_document_ids: [cartItem2.id] }
        end
        it "sets the items' date_downloaded" do
          cartItem2.reload
          expect(cartItem2.date_downloaded.to_date).to eq(Time.now.to_date)
        end
        it "does not change the date downloaded for unselected items in the cart" do
          [cartItem1, cartItem3].each(&:reload)
          expect(cartItem1.date_downloaded).to eq(Date.yesterday)
          expect(cartItem3.date_downloaded).to be(nil)

        end
        it "redirects to media/#zip with the work ids as params" do
          work_id = cartItem2.work_id
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/concern/media/zip?)
          expect(redirect_params["ids[]"]).to eq(work_id)
        end
      end

      context 'the selected items are restricted' do
        before do
          get :download, params: { batch_document_ids: [cartItem5.id,cartItem3.id] }
        end
        it "does not set the items' date_downloaded" do
          [cartItem5,cartItem3].each(&:reload)
          expect(cartItem5.date_downloaded).to be(nil)
          expect(cartItem3.date_downloaded).to be(nil)
        end
        it "does not change the date downloaded for unselected items in the cart" do
          cartItem2.reload
          expect(cartItem2.date_downloaded).to eq(Date.yesterday)
        end
        it "redirects to media/#zip without the work ids as params" do
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/concern/media/zip?)
          expect(redirect_params["ids[]"]).to be(nil)
        end
      end

      context 'the selected items are a mix of restricted and unrestricted' do
        before do
          get :download, params: { batch_document_ids: [cartItem2.id,cartItem3.id] }
        end
        it "sets only the unrestricted item's date_downloaded" do
          [cartItem2,cartItem3].each(&:reload)
          expect(cartItem2.date_downloaded.to_date).to eq(Time.now.to_date)
          expect(cartItem3.date_downloaded).to be(nil)
        end
        it "does not change the date downloaded for unselected items in the cart" do
          [cartItem1, cartItem3].each(&:reload)
          expect(cartItem1.date_downloaded).to eq(Date.yesterday)
        end
        it "redirects to media/#zip with only the unrestricted work ids as params" do
          work_id = cartItem2.work_id
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/concern/media/zip?)
          expect(redirect_params["ids[]"]).to eq(work_id)
        end
      end
    end

    context 'the user uses the download all button' do
      context 'the cart has only unrestricted items' do
        before do
          restricted_items = [cartItem1,cartItem3]
          restricted_items.each do |item|
            item.restricted = false
            item.save
          end
          get :download, params: {}
        end
        it "sets all the items' date_downloaded" do
          [cartItem1,cartItem2,cartItem3].each(&:reload)
          expect(cartItem1.date_downloaded.to_date).to eq(Date.today)
          expect(cartItem2.date_downloaded.to_date).to eq(Date.today)
          expect(cartItem3.date_downloaded.to_date).to eq(Date.today)
        end
        it "redirects to media/#zip with all the work ids as params" do
          work_ids = [cartItem1.work_id,cartItem2.work_id,cartItem3.work_id]
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/concern/media/zip?)
          expect(redirect_params["ids[]"]).to match_array(work_ids)
        end

      end

      context 'the page has only restricted items' do
        before do
          cartItem2.restricted = true
          cartItem2.save
          cartItem1.date_approved = nil
          cartItem1.save
          get :download, params: {}
        end
        it "sets none of the items' date_downloaded" do
          [cartItem1,cartItem2,cartItem3].each(&:reload)
          expect(cartItem1.date_downloaded.to_date).to eq(Date.yesterday)
          expect(cartItem2.date_downloaded.to_date).to eq(Date.yesterday)
          expect(cartItem3.date_downloaded).to be(nil)
        end
        it "redirects to media/#zip with none of the work ids as params" do
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/concern/media/zip?)
          expect(redirect_params["ids[]"]).to eq(nil)
        end
      end

      context 'the page has a mix of restricted and unrestricted items' do
        before do
          get :download, params: {}
        end
        it "sets only the unrestricted items' date_downloaded" do
          [cartItem5,cartItem2,cartItem3].each(&:reload)
          expect(cartItem5.date_downloaded).to be(nil)
          expect(cartItem2.date_downloaded.to_date).to eq(Date.today)
          expect(cartItem3.date_downloaded).to eq(nil)
        end
        it "redirects to media/#zip with only the unrestricted work ids as params" do
          work_ids = [cartItem1.work_id,cartItem2.work_id]
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/concern/media/zip?)
          expect(redirect_params["ids[]"]).to match_array(work_ids)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context 'the user batch selects items to destroy' do
      it "deletes the cart item if it hasn't been downloaded" do
        expect{
          process :destroy, method: :delete, params: {:batch_document_ids => [cartItem1.id,cartItem2.id,cartItem3.id]}
        }.to change{CartItem.count}.by(-1)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been downloaded" do
        delete :destroy, params: {:batch_document_ids => [cartItem1.id,cartItem2.id]}
        [cartItem1,cartItem2].each(&:reload)
        expect(cartItem1.in_cart).to be(false)
        expect(cartItem2.in_cart).to be(false)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been requested" do
        cartItem3.date_requested = Date.yesterday
        cartItem3.save
        delete :destroy, params: {:batch_document_ids => [cartItem3.id]}
        cartItem3.reload
        expect(cartItem3.in_cart).to be(false)
      end

      it "returns flash message 'Item Removed from Cart'" do
        delete :destroy, params: {:batch_document_ids => [cartItem1.id,cartItem2.id,cartItem3.id]}
        expect(response.flash[:notice]).to eq('3 Items Removed from Cart')
      end

      it "refreshes the my cart page" do
        delete :destroy, params: {:batch_document_ids => [cartItem1.id,cartItem2.id,cartItem3.id]}
        expect(response).to redirect_to(my_cart_path)
      end
    end

    context 'removes one item using the individual button' do
      it "deletes the cart item if it hasn't been downloaded or requested" do
        expect{
          process :destroy, method: :delete, params: {:item_id => cartItem3.id}
        }.to change{CartItem.count}.by(-1)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been downloaded" do
        delete :destroy, params: {:item_id => cartItem2.id}
        cartItem2.reload
        expect(cartItem2.in_cart).to be(false)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been requested" do
        cartItem3.date_requested = Date.yesterday
        cartItem3.save
        delete :destroy, params: {:item_id => cartItem3.id}
        cartItem3.reload
        expect(cartItem3.in_cart).to be(false)
      end

      it "returns flash message 'Item Removed from Cart'" do
        delete :destroy, params: {:item_id => cartItem3.id}
        expect(response.flash[:notice]).to eq('1 Item Removed from Cart')
      end

      it "refreshes the my cart page" do
        delete :destroy, params: {:item_id => cartItem3.id}
        expect(response).to redirect_to(my_cart_path)
      end
    end
    context 'removes all items using the clear cart button' do
      it "deletes the cart item if it hasn't been downloaded or requested" do
        expect{
          process :destroy, method: :delete, params: {}
        }.to change{CartItem.count}.by(-1)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been downloaded" do
        delete :destroy, params: {}
        [cartItem1,cartItem2].each(&:reload)
        expect(cartItem1.in_cart).to be(false)
        expect(cartItem2.in_cart).to be(false)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been requested" do
        cartItem3.date_requested = Date.yesterday
        cartItem3.save
        delete :destroy, params: {}
        cartItem3.reload
        expect(cartItem3.in_cart).to be(false)
      end

      it "returns flash message 'Item Removed from Cart'" do
        delete :destroy, params: {}
        expect(response.flash[:notice]).to eq('3 Items Removed from Cart')
      end

      it "refreshes the my cart page" do
        delete :destroy, params: {}
        expect(response).to redirect_to(my_cart_path)
      end
    end
  end
end
