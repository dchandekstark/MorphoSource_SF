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

    before do
      get :index
    end

    include_examples '#index'
    include_examples '#get_items instance variables', 'request manager'

  end

  describe "PUT #approve_download" do
    context 'the data manager approves one request' do
      before do
        put :approve_download, params: { item_id: cartItem1.id }
        cartItem1.reload
      end
      it "marks the item's date approved to today" do
        expect(cartItem1.date_approved.to_date).to eq(Date.today)
      end
      it "marks the item's date expired to tomorrow" do
        expect(cartItem1.date_expired.to_date).to eq(Date.tomorrow)
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
        put :approve_download, params: { batch_document_ids: [cartItem1.id,cartItem5.id] }
        [cartItem1,cartItem5].each(&:reload)
      end
      it "marks the items' date approved to today" do
        expect(cartItem1.date_approved.to_date).to eq(Date.today)
        expect(cartItem5.date_approved.to_date).to eq(Date.today)
      end
      it "marks the items' date expired to tomorrow" do
        expect(cartItem1.date_expired.to_date).to eq(Date.tomorrow)
        expect(cartItem5.date_expired.to_date).to eq(Date.tomorrow)
      end
      it "creates a flash message with the number of items approved" do
        expect(response.flash[:notice]).to eq("2 Items Approved for Download")
      end
      it "redirects to the request manager page" do
        expect(response).to redirect_to(request_manager_path)
      end
    end
  end

  describe "PUT #deny_download" do
    before do
      put :deny_download, params: { item_id: cartItem1.id }
      cartItem1.reload
    end
    it "marks the item's date denied to today" do
      expect(cartItem1.date_denied.to_date).to eq(Date.today)
    end
    it "creates a flash message" do
      expect(response.flash[:notice]).to eq("Download Denied")
    end
    it "redirects to the request manager page" do
      expect(response).to redirect_to(request_manager_path)
    end
  end

end
