# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'
require 'iiif_manifest'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::CartItemsController, :type => :controller  do

  # Work already added to cart
  let(:work)          { Media.create(id: "aaa", title: ["Test Media Work"])}
  # Work not yet added to cart
  let(:work2)         { Media.create(id: "fff", title: ["Test Media Work"])}

  let(:current_user)  { User.create(id: 1, email: "example@email.com", password: "password") }
  let(:media_cart)    { MediaCart.where(user_id: current_user.id)[0] }
  let(:cartItem1)     { CartItem.create( media_cart_id: media_cart.id, work_id: "aaa") }
  let(:cartItem2)     { CartItem.create( media_cart_id: media_cart.id, work_id: "bbb") }
  let(:cartItem3)     { CartItem.create( media_cart_id: media_cart.id, work_id: "ccc") }
  let(:cartItem4)     { CartItem.create( media_cart_id: media_cart.id, work_id: "ddd", downloaded: true) }
  let(:cartItem5)     { CartItem.create( media_cart_id: media_cart.id, work_id: "eee", downloaded: true) }

  let(:allCartItems)  { [cartItem1, cartItem2, cartItem3, cartItem4, cartItem5] }

  before do
    allCartItems.each{ |i| i.touch }
    sign_in current_user
  end

  describe "#search_builder_class" do

    context "user views the media cart" do
      before do
        allow(subject).to receive_message_chain(:request, :original_fullpath).and_return('/dashboard/my/cart')
      end

      it 'returns the CartItems Search Builder' do
        expect(subject.search_builder_class).to eq (Morphosource::My::CartItems::CartItemsSearchBuilder)
      end
    end

    context "user views their previous downloads" do
      before do
        allow(subject).to receive_message_chain(:request, :original_fullpath).and_return('/dashboard/my/downloads')
      end

      it 'returns the Downloads Search Builder' do
        expect(subject.search_builder_class).to eq (Morphosource::My::CartItems::DownloadsSearchBuilder)
      end
    end
  end

  describe "#works_in_cart" do

    it "returns only cart items that have not yet been downloaded" do
      expect(subject.send(:works_in_cart)).to match_array(["aaa","bbb","ccc"])
    end
  end

  describe "#create" do

    context 'item is not in cart' do
      let(:post_params) { {:media_cart_id => media_cart.id, :work_id => work2.id, :work_type => "Media"} }

      it "creates a new CartItem" do
        expect{
          process :create, method: :post, params: post_params
          }.to change{CartItem.count}.by(1)
      end

      it "returns flash message 'Item Added to Cart'" do
        post :create, params: post_params
        expect(response.flash[:notice]).to eq('Item Added to Cart')
      end
    end

    context "item is already in the user's cart" do
      let(:post_params) { {:media_cart_id => media_cart.id, :work_id => work.id, :work_type => "Media"} }

      it "creates a new CartItem" do
        expect{
          process :create, method: :post, params: post_params
        }.to change{CartItem.count}.by(0)
      end

      it "returns flash message 'Item Already in Cart'" do
        post :create, params: post_params
        expect(response.flash[:alert]).to eq('Item Already in Cart')
      end
    end

    describe "#destroy" do

      it "deletes the cart item" do
        expect{
          process :destroy, method: :delete, params: {:id => cartItem1.id}
        }.to change{CartItem.count}.by(-1)
      end

      it "returns flash message 'Item Removed from Cart'" do
        delete :destroy, params: {:id => cartItem1.id}
        expect(response.flash[:notice]).to eq('Item Removed from Cart')
      end
    end
  end
end
