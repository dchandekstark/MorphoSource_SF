# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'
require 'iiif_manifest'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::CartItemsController, :type => :controller  do

  include_context 'cart items'

  describe "POST #create" do

    context 'item is not in cart' do
      let(:post_params) { {:media_cart_id => media_cart.id, :work_id => work6.id, :work_type => "Media" } }

      it "creates a new CartItem" do
        expect{
          process :create, method: :post, params: post_params
          }.to change{CartItem.count}.by(1)
      end

      it "creates the correct metadata" do
        post :create, params: post_params
        item = CartItem.last
        expect(item.media_cart_id).to eq(media_cart.id)
        expect(item.work_id).to eq(work6.id)
        expect(item.in_cart).to be(true)
        expect(item.restricted).to be(work6.restricted?)
        expect(item.approver).to eq(work6.depositor)
      end

      it "returns flash message 'Item Added to Cart'" do
        post :create, params: post_params
        expect(response.flash[:notice]).to eq('Item Added to Cart')
      end

      it "should call 'after_create_response' with @curation_concern" do
        expect(subject).to receive(:after_create_response).with(work6)
        post :create, params: post_params
      end

      context 'work is restricted' do
        before do
          allow(work6).to receive(:restricted?).and_return(true)
          post :create, params: post_params
        end

        it 'creates a restricted cart item' do
          item = CartItem.last
          expect(item.restricted).to be(true)
        end
      end

      context 'work is restricted but user is media manager' do
        before do
          allow(work6).to receive(:restricted?).and_return(true)
          allow(work6).to receive(:depositor).and_return(current_user.email)
          post :create, params: post_params
        end

        it 'changes the item to unrestricted' do
          item = CartItem.last
          expect(item.restricted).to be(false)
        end
      end
    end

    context 'item is already in cart' do
      let(:post_params) { {:media_cart_id => media_cart.id, :work_id => work2.id, :file_accessibility => "open", :work_type => "Media"} }

      it "Does not create a new CartItem" do
        expect{
          process :create, method: :post, params: post_params
        }.to change{CartItem.count}.by(0)
      end

      it "returns flash message 'Item Already in Cart'" do
        post :create, params: post_params
        expect(response.flash[:alert]).to eq('Item Already in Cart')
      end

      it "should call 'after_create_response' with @curation_concern" do
        expect(subject).to receive(:after_create_response).with(work2)
        post :create, params: post_params
      end
    end
  end
end
