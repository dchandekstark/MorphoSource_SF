require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user)          { User.create(email: "example@email.com", password: "password") }
  let(:data_owner)    { User.create(email: "test@test.com", password: "password") }

  let(:media_cart)    { MediaCart.where(user_id: user.id)[0] }
  let(:work)          { Media.create(id: "aaa", title: ["Test Media Work"], depositor: "test@test.com", fileset_accessibility: ['open'])}
  let(:cartItem1)     { CartItem.create(id: 1, media_cart_id: media_cart.id, work_id: "aaa", in_cart: true, restricted: true) }
  let(:cartItem2)     { CartItem.create(id: 2, media_cart_id: media_cart.id, work_id: "bbb", in_cart: true, restricted: false) }
  let(:cartItem3)     { CartItem.create(id: 3, media_cart_id: media_cart.id, work_id: "ccc", in_cart: true, restricted: true, date_requested: Date.yesterday) }
  let(:cartItem4)     { CartItem.create(id: 4, media_cart_id: media_cart.id, work_id: "ddd", in_cart: false, date_downloaded: Time.current) }
  let(:cartItem5)     { CartItem.create(id: 5, media_cart_id: media_cart.id, work_id: "eee", in_cart: false, restricted: true, date_downloaded: Time.current, date_requested: Date.yesterday) }

  let(:allCartItems)  { [cartItem1, cartItem2, cartItem3, cartItem4, cartItem5] }

  before do
    allow(Media).to receive(:find).with(anything()).and_return(work)
    # Makes user aware of its cart_items
    allCartItems.each(&:touch)
  end

  describe '#create_user_media_cart' do
    it 'creates a media cart for every new user' do
      user2 = User.create({email: 'email@example.com', password: "password"})
      expect(user2.media_cart.present?).to be(true)
    end
  end

  describe '#cart_id' do
    it { expect(user.cart_id).to eq(media_cart.id) }
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

  describe '#restricted_items_in_cart' do
    it { expect(user.restricted_items_in_cart).to match_array([cartItem1,cartItem3])}
  end

  describe '#restricted_items_in_cart_ids' do
    it { expect(user.restricted_items_in_cart_ids).to match_array([cartItem1.id,cartItem3.id])}
  end

  # where user is requestor
  describe '#my_requests' do
    it { expect(user.my_requests).to match_array([cartItem3,cartItem5])}
  end

  describe '#my_requests_ids' do
    it { expect(user.my_requests_ids).to match_array([cartItem3.id,cartItem5.id])}
  end

  describe '#my_requests_work_ids' do
    it { expect(user.my_requests_work_ids).to match_array([cartItem3.work_id,cartItem5.work_id])}
  end

  # where user is data owner/manager
  describe '#requested_items' do
    it { expect(data_owner.requested_items).to match_array([cartItem3,cartItem5])}
  end

  describe '#requested_item_ids' do
    it { expect(data_owner.requested_item_ids).to match_array([cartItem3.id,cartItem5.id])}
  end

  describe '#requested_items_work_ids' do
    it { expect(data_owner.requested_items_work_ids).to match_array([cartItem3.work_id,cartItem5.work_id])}
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
