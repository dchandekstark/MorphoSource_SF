require 'rails_helper'
require 'iiif_manifest'

include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::RequestManagersController, :type => :controller  do

  include_context 'cart items'

  before do
    restricted_items = [cartItem1,cartItem3,cartItem5,cartItem7]
    restricted_items.each do |item|
      item.approver = current_user
      item.save
    end
  end

  describe "GET #index" do

    context 'normal index stuff' do
      before do
        get :index
      end

      include_examples '#index'

    end

    context 'user looks at new requests' do
      before do
        get :index
      end

      include_examples '#get_items instance variables', 'request manager'
    end

    context 'user looks at previous requests' do

      before do
        allow(subject).to receive(:previous_requests?).and_return(true)
        get :index
      end

      include_examples '#get_items instance variables', 'previous requests'
    end

  end

  describe "PUT #approve_download" do
    context 'the data manager approves one request' do
      before do
        put :approve_download, params: { item_id: cartItem1.id, expiration_date: [1.month.from_now] }
        cartItem1.reload
      end
      it "marks the item's date approved to today" do
        expect(cartItem1.date_approved.to_date).to eq(Date.today)
      end
      it "marks the item's date expired to one month from now" do
        expect(cartItem1.date_expired.to_date).to eq(1.month.from_now.to_date)
      end
      it "creates a flash message with the number of items approved" do
        expect(response.flash[:notice]).to eq("1 Item Approved for Download")
      end
      it "redirects to the request manager page" do
        expect(response).to redirect_to(request_manager_path)
      end
    end
    context 'the data manager approves multiple requests' do
      before do
        put :approve_download, params: { batch_document_ids: [cartItem1.id,cartItem5.id], expiration_date: [1.month.from_now] }
        [cartItem1,cartItem5].each(&:reload)
      end
      it "marks the items' date approved to today" do
        expect(cartItem1.date_approved.to_date).to eq(Date.today)
        expect(cartItem5.date_approved.to_date).to eq(Date.today)
      end
      it "marks the items' date expired to one month from now" do
        expect(cartItem1.date_expired.to_date).to eq(1.month.from_now.to_date)
        expect(cartItem5.date_expired.to_date).to eq(1.month.from_now.to_date)
      end
      it "creates a flash message with the number of items approved" do
        expect(response.flash[:notice]).to eq("2 Items Approved for Download")
      end
      it "redirects to the request manager page" do
        expect(response).to redirect_to(request_manager_path)
      end
    end
  end

  describe 'PUT #clear_request' do
    before do
      put :clear_request, params: { item_id: cartItem5.id }
      cartItem5.reload
    end
    it "clears the item's date requested" do
      expect(cartItem5.date_requested).to be(nil)
    end
    it 'marks the date cleared as today' do
      expect(cartItem5.date_cleared.to_date).to eq(Date.today)
    end
    it 'creates a flash message' do
      expect(response.flash[:notice]).to eq("Request cleared for 1 Item")
    end
    it 'redirects to the request manager page' do
      expect(response).to redirect_to(request_manager_path)
    end
  end

  describe "PUT #deny_download" do
    before do
      put :deny_download, params: { item_id: cartItem5.id }
      cartItem5.reload
    end
    it "marks the item's date denied to today" do
      expect(cartItem5.date_denied.to_date).to eq(Date.today)
    end
    it "creates a flash message" do
      expect(response.flash[:notice]).to eq("Download Denied")
    end
    it "redirects to the request manager page" do
      expect(response).to redirect_to(request_manager_path)
    end
  end

  describe 'PUT #edit_expiration' do
    before do
      put :edit_expiration, params: { item_id: cartItem1.id, expiration_date: [Date.yesterday] }
    end
    it "marks the item's expiration date as yesterday" do
      cartItem1.reload
      expect(cartItem1.date_expired.to_date).to eq(Date.yesterday)
    end
    it "creates a flash message" do
      expect(response.flash[:notice]).to eq("Expiration Date Updated")
    end
    it "redirects to the request manager page" do
      expect(response).to redirect_to(previous_requests_path)
    end
  end

end
