require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user)  { User.create(id: 1, email: "example@email.com", password: "password") }
  let(:media_cart)    { MediaCart.where(user_id: user.id)[0] }
  let(:cartItem1)     { CartItem.create(id: 1, media_cart_id: media_cart.id, work_id: "aaa") }
  let(:cartItem2)     { CartItem.create(id: 2, media_cart_id: media_cart.id, work_id: "bbb") }
  let(:cartItem3)     { CartItem.create(id: 3, media_cart_id: media_cart.id, work_id: "ccc") }
  let(:cartItem4)     { CartItem.create(id: 4, media_cart_id: media_cart.id, work_id: "ddd", downloaded: true) }
  let(:cartItem5)     { CartItem.create(id: 5, media_cart_id: media_cart.id, work_id: "eee", downloaded: true) }

  let(:allCartItems)  { [cartItem1, cartItem2, cartItem3, cartItem4, cartItem5] }

  before do
    # Makes user aware of its cart_items
    allCartItems.each{ |i| i.touch }
  end

  describe '#create_user_media_cart' do

    it 'creates a media cart for every new user' do
      user2 = User.create({email: 'email@example.com', password: "password"})
      expect(user2.media_cart.present?).to be(true)
    end
  end

  describe '#items_in_cart' do
    it "returns all cart items in the user's shopping cart" do
      expect(user.items_in_cart).to match_array([cartItem1, cartItem2, cartItem3])
    end
  end

  describe '#work_ids_in_cart' do
    it "returns the work ids of items in the user's shopping cart" do
      expect(user.work_ids_in_cart).to match_array([cartItem1.work_id, cartItem2.work_id, cartItem3.work_id])
    end
  end

  describe '#downloaded_items' do
    it "returns items the user has downloaded" do
      expect(user.downloaded_items).to match_array([cartItem4, cartItem5])
    end
  end

  describe '#downloaded_work_ids' do
    it "returns the work ids for items the user has downloaded" do
      expect(user.downloaded_work_ids).to match_array([cartItem4.work_id, cartItem5.work_id])
    end
  end
end
