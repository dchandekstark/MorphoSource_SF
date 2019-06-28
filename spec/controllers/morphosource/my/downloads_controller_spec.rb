require 'rails_helper'
require 'iiif_manifest'

include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::DownloadsController, :type => :controller  do

  include_context 'cart items'

  describe "GET #index" do

    before do
      get :index
    end

    include_examples '#index'
    include_examples '#get_items instance variables', 'downloads'

    it 'does not retrieve documents for undownloaded works' do
      expect(subject.instance_variable_get(:@solr_docs)).not_to include(doc3,doc5,doc6)
    end

    it 'does not retrieve items for undownloaded works' do
      expect(subject.instance_variable_get(:@items)).not_to include(cartItem3,cartItem5,cartItem6)
    end
  end

  describe '#batch_create' do

    context 'the selected works are not already in the cart' do
      it "creates new cart items for all works" do
        expect{
          process :batch_create, method: :get, params: {:batch_document_ids => [cartItem4.id,cartItem5.id,cartItem6.id]}
        }.to change{CartItem.count}.by(3)
      end

      it "displays a flash message" do
        get :batch_create, params: {:batch_document_ids => [cartItem4.id, cartItem5.id, cartItem6.id]}
        expect(response.flash[:notice]).to eq("3 Items Added to Cart")
      end
    end

    context 'the selected works are already in the cart' do
      it "does not create new cart items" do
        expect{
          process :batch_create, method: :get, params: {:batch_document_ids => [cartItem1.id, cartItem2.id,cartItem3.id]}
        }.to change{CartItem.count}.by(0)
      end

      it "displays a flash message with duplicates" do
        get :batch_create, params: {:batch_document_ids => [cartItem1.id, cartItem2.id, cartItem3.id]}
        expect(response.flash[:notice]).to eq("0 Items Added to Cart; 3 Items: Maaa: Test Media Work, Mbbb: Test Media Work, Mccc: Test Media Work Already in Your Cart.")
      end
    end

    it 'redirects to the media cart' do
      get :batch_create, params: {:batch_document_ids => [cartItem4.id]}
      expect(response).to redirect_to(my_cart_path)
    end

  end
end
