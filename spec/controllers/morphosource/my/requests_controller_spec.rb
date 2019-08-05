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

    context "user requests multiple items" do
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
  end

  describe "GET #request_again" do

    context "user requests one item again" do
      before do
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
      end

      it "reloads the page" do
        expect(response).to redirect_to("original_page")
      end
    end

    context "user requests multiple items again" do
      before do
        request.env["HTTP_REFERER"] = "original_page"
        get :request_again, params: { batch_document_ids: [cartItem1.id,cartItem5] }
      end

      it "removes any items in the cart" do
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

        expect(item2.media_cart_id).to eq(current_user.media_cart.id)
        expect(item2.work_id).to eq(work2.id)
        expect(item2.in_cart).to be(true)
        expect(item2.approver).to eq(work2.depositor)
        expect(item2.date_requested.to_date).to eq(Date.today)
        expect(item2.restricted).to be(work2.restricted?)
      end

      it "reloads the page" do
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
end
