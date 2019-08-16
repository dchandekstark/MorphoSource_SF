require 'rails_helper'
require 'iiif_manifest'

include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::RequestsController, :type => :controller  do

  include_context 'cart items'

  describe "GET #index" do

    before do
      get :index
    end

    include_examples '#index'
    include_examples '#get_items instance variables', 'requests'

  end

  describe "PUT #request_item" do
    context "user requests one item" do
      context 'the item has not been requested before' do
        before do
          request.env["HTTP_REFERER"] = "original_page"
          put :request_item, params: { item_id: cartItem3.id }
        end

        it "marks the item's date_requested as today" do
          cartItem3.reload
          expect(cartItem3.date_requested.to_date).to eq(Date.today)
        end

        it "creates a flash notice with the number of items requested" do
          expect(response.flash[:notice]).to eq("1 Item Requested")
        end

        it "reloads the page" do
          expect(response).to redirect_to("original_page")
        end
      end

      context 'the item has been requested before and cleared' do
        before do
          cartItem3.date_cleared = Date.yesterday
          cartItem3.save
          request.env["HTTP_REFERER"] = "original_page"
          put :request_item, params: { item_id: cartItem3.id }
        end

        it "marks the item's date_requested as today" do
          cartItem3.reload
          expect(cartItem3.date_requested.to_date).to eq(Date.today)
        end

        it "removes the date cleared" do
          cartItem3.reload
          expect(cartItem3.date_cleared).to be(nil)
        end

        it "creates a flash notice with the number of items requested" do
          expect(response.flash[:notice]).to eq("1 Item Requested")
        end

        it "reloads the page" do
          expect(response).to redirect_to("original_page")
        end
      end

      context 'the item is a previous request' do
        let(:requested_work) { Media.create(id: "zzz", title: ["Test Media Work"], depositor: "test@test.com", fileset_accessibility: ['restricted_download'])}
        let(:requested_item) { CartItem.create(media_cart_id: media_cart.id, work_id: requested_work.id, in_cart: true, date_requested: Date.yesterday, date_approved: Date.yesterday, date_expired: Date.yesterday, restricted: true)}
        let(:put_params) { {item_id: requested_item.id} }

        before do
          request.env["HTTP_REFERER"] = "original_page"
          allow(Media).to receive(:find).with('zzz').and_return(requested_work)
          requested_item.touch
        end

        it 'marks the item as not being in the cart' do
          put :request_item, params: put_params
          requested_item.reload
          expect(requested_item.in_cart).to be(false)
        end

        it 'creates a new cart item' do
          expect{
            process :request_item, method: :put, params: { item_id: requested_item.id }
          }.to change{CartItem.count}.by(1)
        end

        it 'assigns the correct attribute values to the new cart item' do
          put :request_item, params: put_params
          item = CartItem.last
          work = requested_work
          expect(item.media_cart_id).to eq(current_user.media_cart.id)
          expect(item.work_id).to eq(work.id)
          expect(item.approver).to eq(work.depositor)
          expect(item.date_requested.to_date).to eq(Date.today)
          expect(item.restricted).to be(true)
          expect(item.in_cart).to be(true)
          expect(item.date_cleared).to be(nil)
        end

        it "reloads the page" do
          put :request_item, params: put_params
          expect(response).to redirect_to("original_page")
        end
      end
    end

    context "user requests multiple items" do
      context 'none of the items has been requested before' do
        before do
          request.env["HTTP_REFERER"] = "original_page"
          put :request_item, params: { batch_document_ids: [cartItem3.id,cartItem7.id] }
        end

        it "marks the items' date_requested as today" do
          [cartItem3,cartItem7].each(&:reload)
          expect(cartItem3.date_requested.to_date).to eq(Date.today)
          expect(cartItem7.date_requested.to_date).to eq(Date.today)
        end

        it "creates a flash notice with the number of items requested" do
          expect(response.flash[:notice]).to eq("2 Items Requested")
        end

        it "reloads the page" do
          expect(response).to redirect_to("original_page")
        end
      end

      context 'some of the items have been requested before' do
        before do
          cartItem1.date_expired = Date.yesterday
          cartItem1.save
          request.env["HTTP_REFERER"] = "original_page"
          put :request_item, params: { batch_document_ids: [cartItem3.id,cartItem7.id,cartItem1.id] }
        end

        it "marks the previously unrequested items' date_requested as today" do
          [cartItem3,cartItem7].each(&:reload)
          expect(cartItem3.date_requested.to_date).to eq(Date.today)
          expect(cartItem7.date_requested.to_date).to eq(Date.today)
        end

        it 'removes the previously requested items from the cart' do
          cartItem1.reload
          expect(cartItem1.in_cart).to be(false)
        end

        it 'assigns the correct attribute values to the new cart item' do
          item = CartItem.last
          work = Media.find(cartItem1.work_id)
          expect(item.media_cart_id).to eq(current_user.media_cart.id)
          expect(item.work_id).to eq(work.id)
          expect(item.in_cart).to be(true)
          expect(item.approver).to eq(work.depositor)
          expect(item.date_requested.to_date).to eq(Date.today)
          expect(item.restricted).to be(work.restricted?)
          expect(item.date_cleared).to be(nil)
        end

        it "creates a flash notice with the number of items requested" do
          expect(response.flash[:notice]).to eq("3 Items Requested")
        end

        it "reloads the page" do
          expect(response).to redirect_to("original_page")
        end
      end

      context 'one item in group has already been requested' do
        before do
          cartItem1.date_expired = Date.yesterday
          cartItem1.save
        end
        it 'creates a new cart item' do
          expect{
            process :request_item, method: :put, params: { batch_document_ids: [cartItem3.id,cartItem7.id,cartItem1.id] }
          }.to change{CartItem.count}.by(1)
        end
      end
    end
  end

  describe "GET #request_again" do

    context "user requests one item again" do
      before do
        cartItem1.date_expired = Date.yesterday
        cartItem1.save
        request.env["HTTP_REFERER"] = "original_page"
        get :request_again, params: { item_id: cartItem1.id }
      end

      it "removes the item from the cart" do
        cartItem1.reload
        expect(cartItem1.in_cart).to be(false)
      end

      it 'creates a new cart item' do
        expect{
          process :request_again, method: :get, params: { item_id: cartItem1.id }
        }.to change{CartItem.count}.by(1)
      end

      it 'assigns the correct attribute values to the new cart item' do
        item = CartItem.last
        work = Media.find(cartItem1.work_id)
        expect(item.media_cart_id).to eq(current_user.media_cart.id)
        expect(item.work_id).to eq(work.id)
        expect(item.in_cart).to be(true)
        expect(item.approver).to eq(work.depositor)
        expect(item.date_requested.to_date).to eq(Date.today)
        expect(item.restricted).to be(work.restricted?)
        expect(item.date_cleared).to be(nil)
      end

      it "reloads the page" do
        expect(response).to redirect_to("original_page")
      end
    end

    context "user requests multiple items again" do
      before do
        cartItem1.date_expired = Date.yesterday
        cartItem1.save
        cartItem5.date_denied = Date.yesterday
        cartItem5.save
        request.env["HTTP_REFERER"] = "original_page"
      end

      it "removes any items in the cart" do
        get :request_again, params: { batch_document_ids: [cartItem1.id,cartItem5.id] }
        [cartItem1,cartItem5].each(&:reload)
        expect(cartItem1.in_cart).to be(false)
        expect(cartItem5.in_cart).to be(false)
      end

      it 'creates new cart items' do
        expect{
          process :request_again, method: :get, params: { batch_document_ids: [cartItem1.id,cartItem5.id] }
        }.to change{CartItem.count}.by(2)
      end

      it 'assigns the correct attribute values to the new cart items' do
        get :request_again, params: { batch_document_ids: [cartItem1.id,cartItem5.id] }
        items = CartItem.limit(2).order('id desc')
        item1 = items[0]
        work1 = Media.find(item1.work_id)
        item2 = items[1]
        work2 = Media.find(item2.work_id)

        expect(item1.media_cart_id).to eq(current_user.media_cart.id)
        expect(item1.work_id).to eq(work1.id)
        expect(item1.in_cart).to be(true)
        expect(item1.approver).to eq(work1.depositor)
        expect(item1.date_requested.to_date).to eq(Date.today)
        expect(item1.restricted).to be(work1.restricted?)
        expect(item1.date_cleared).to be(nil)

        expect(item2.media_cart_id).to eq(current_user.media_cart.id)
        expect(item2.work_id).to eq(work2.id)
        expect(item2.in_cart).to be(true)
        expect(item2.approver).to eq(work2.depositor)
        expect(item2.date_requested.to_date).to eq(Date.today)
        expect(item2.restricted).to be(work2.restricted?)
        expect(item2.date_cleared).to be(nil)
      end

      it "reloads the page" do
        get :request_again, params: { batch_document_ids: [cartItem1.id,cartItem5.id] }
        expect(response).to redirect_to("original_page")
      end
    end
  end

  describe "PUT #cancel_request" do
    before do
      request.env["HTTP_REFERER"] = "original_page"
      put :cancel_request, params: { item_id: cartItem1.id }
    end
    it "marks the cart item as canceled" do
      cartItem1.reload
      expect(cartItem1.date_canceled.to_date).to eq(Date.today)
    end
    it 'creates a new flash message' do
      expect(response.flash[:notice]).to eq("Request Canceled")
    end
    it "reloads the page" do
      expect(response).to redirect_to("original_page")
    end
  end

  describe "PUT #move_to_cart" do
    before do
      request.env["HTTP_REFERER"] = "original_page"
      put :move_to_cart, params: { item_id: cartItem5.id }
    end
    it "marks the cart item as in_cart" do
      cartItem5.reload
      expect(cartItem5.in_cart).to be(true)
    end
    it 'creates a new flash message' do
      expect(response.flash[:notice]).to eq("Item Moved to Cart")
    end
    it "reloads the page" do
      expect(response).to redirect_to("original_page")
    end
  end

  describe "POST #request_work" do
    context "work is not in the user's cart and hasn't been requested" do
      let(:new_work)    { Media.create(id: 'zzz', fileset_accessibility: ["restricted_download"], depositor: 'test@test.com')}
      let(:post_params) { { work_id: new_work.id } }
      before do
        request.env["HTTP_REFERER"] = "original_page"
        allow(Media).to receive(:find).with('zzz').and_return(new_work)
      end

      it "creates a new CartItem" do
        expect{
          process :request_work, method: :post, params: post_params
          }.to change{CartItem.count}.by(1)
      end

      it "creates the correct metadata" do
        post :request_work, params: post_params
        item = CartItem.last
        expect(item.media_cart_id).to eq(media_cart.id)
        expect(item.work_id).to eq(new_work.id)
        expect(item.in_cart).to be(true)
        expect(item.restricted).to be(new_work.restricted?)
        expect(item.approver).to eq(new_work.depositor)
      end
    end
    context "work is in the cart and hasn't been requested" do
      let(:post_params) { {work_id: work3.id} }
      before do
        request.env["HTTP_REFERER"] = "original_page"
        post :request_work, params: post_params
        cartItem3.reload
      end
      it "marks the item as requested and leaves it in the cart" do
        expect(cartItem3.in_cart).to be(true)
        expect(cartItem3.date_requested.to_date).to eq(Date.today)
      end
      it "reloads the page" do
        expect(response).to redirect_to("original_page")
      end
    end
    context "work is in the cart, but is an inactive request (expired,denied,cleared,canceled)" do
      let(:post_params) {{work_id: cartItem1.work_id}}
      before do
        request.env["HTTP_REFERER"] = "original_page"
        cartItem1.date_expired = Date.yesterday
        cartItem1.save
      end

      it "creates a new cart Item" do
        expect{
          process :request_work, method: :post, params: post_params
        }.to change{CartItem.count}.by(1)
      end

      it "removes the original item from the cart" do
        expect{
          process :request_work, method: :post, params: post_params
        }.to change{cartItem1.reload.in_cart}.from(true).to(false)
      end

      it "reloads the page" do
        post :request_work, params: post_params
        expect(response).to redirect_to("original_page")
      end
    end
  end
end
