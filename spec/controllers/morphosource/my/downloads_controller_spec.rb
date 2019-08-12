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

      it 'assigns the correct metadata to the new cart item' do
        get :batch_create, params: {:batch_document_ids => [cartItem4.id]}
        item = CartItem.last
        expect(item.work_id).to eq(work4.id)
        expect(item.media_cart_id).to eq(current_user.media_cart.id)
        expect(item.in_cart).to be(true)
        expect(item.restricted).to be(work4.restricted?)
        expect(item.approver).to eq(work4.depositor)
      end

      context 'the user selects duplicate works' do
        let(:cartItem10) {double("CartItem", id: 555555, work_id: cartItem4.work_id )}
        let(:cartItem11) {double("CartItem", id: 666666, work_id: cartItem4.work_id )}

        before do
          allow(CartItem).to receive(:where).with(id: [cartItem4.id.to_s, cartItem10.id.to_s, cartItem11.id.to_s]).and_return([cartItem4,cartItem10,cartItem11])
        end

        it "creates one cart item for each unique work" do
          expect{
            process :batch_create, method: :get, params: {:batch_document_ids => [cartItem4.id,cartItem10.id,cartItem11.id]}
          }.to change{CartItem.count}.by(1)
        end

        it 'has the correct flash message' do
          get :batch_create, params: {:batch_document_ids => [cartItem4.id,cartItem10.id,cartItem11.id]}
          expect(response.flash[:notice]).to eq("1 Item Added to Cart; 2 Items: Mddd: Test Media Work, Mddd: Test Media Work Already in Your Cart.")
        end

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
        expect(response.flash[:notice]).to eq("0 Items Added to Cart; 3 Items: Test Media Work, Test Media Work, Test Media Work Already in Your Cart.")
      end
    end

    it 'redirects to the media cart' do
      get :batch_create, params: {:batch_document_ids => [cartItem4.id]}
      expect(response).to redirect_to(my_cart_path)
    end

  end
end
