# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'
require 'iiif_manifest'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::CartItemsController, :type => :controller  do

  # Work already added to cart
  let(:work)          { Media.create(id: "aaa", title: ["Test Media Work"])}
  # Work not yet added to cart
  let(:work22)         { Media.create(id: "zzz", title: ["Test Media Work"])}

  let(:current_user)  { User.create(id: 1, email: "example@email.com", password: "password") }
  let(:media_cart)    { MediaCart.where(user_id: current_user.id)[0] }
  let(:cartItem1)     { CartItem.create( media_cart_id: media_cart.id, work_id: "aaa", in_cart: true, date_downloaded: nil) }
  let(:cartItem2)     { CartItem.create( media_cart_id: media_cart.id, work_id: "bbb", in_cart: true, date_downloaded: nil) }
  let(:cartItem3)     { CartItem.create( media_cart_id: media_cart.id, work_id: "ccc", in_cart: true, date_downloaded: nil) }
  let(:cartItem4)     { CartItem.create( media_cart_id: media_cart.id, work_id: "ddd", in_cart: true, date_downloaded: Time.current) }
  let(:cartItem5)     { CartItem.create( media_cart_id: media_cart.id, work_id: "eee", in_cart: false, date_downloaded: Time.current) }
  let(:cartItem6)     { CartItem.create( media_cart_id: media_cart.id, work_id: "fff", in_cart: false, date_downloaded: Time.current) }


  let(:allCartItems)  { [cartItem1, cartItem2, cartItem3, cartItem4, cartItem5, cartItem6] }

  let(:doc1)          { SolrDocument.new(id: "aaa") }
  let(:doc2)          { SolrDocument.new(id: "bbb") }
  let(:doc3)          { SolrDocument.new(id: "ccc") }
  let(:doc4)          { SolrDocument.new(id: "ddd") }
  let(:doc5)          { SolrDocument.new(id: "eee") }
  let(:doc6)          { SolrDocument.new(id: "fff") }

  before do
    allCartItems.each{ |i| i.touch }
    sign_in current_user
  end

  describe "#" do
    before do
      allow(SolrDocument).to receive(:find).with(cartItem1.work_id).and_return(doc1)
      allow(SolrDocument).to receive(:find).with(cartItem2.work_id).and_return(doc2)
      allow(SolrDocument).to receive(:find).with(cartItem3.work_id).and_return(doc3)
      allow(SolrDocument).to receive(:find).with(cartItem4.work_id).and_return(doc4)
      allow(SolrDocument).to receive(:find).with(cartItem5.work_id).and_return(doc5)
      allow(SolrDocument).to receive(:find).with(cartItem6.work_id).and_return(doc6)
    end

    context "user views the media cart" do
      before do
        get :media_cart
      end

      it 'returns documents for works in the media cart' do
        expect(subject.send(:solr_docs)).to match_array([doc1,doc2,doc3,doc4])
      end
    end

    context "user views their previous downloads" do
      before do
        get :previous_downloads
      end

      it 'returns documents for previously downloaded works' do
        expect(subject.send(:solr_docs)).to match_array([doc4,doc5,doc6])
      end
    end
  end

  describe "#works_in_cart" do
    it "returns only cart items that have not yet been downloaded" do
      expect(subject.send(:works_in_cart)).to match_array(["aaa","bbb","ccc","ddd"])
    end
  end

  describe "#create" do

    context 'item is not in cart' do
      let(:post_params) { {:media_cart_id => media_cart.id, :work_id => work22.id, :work_type => "Media", :fileset_accessibility => 'open'} }

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

    describe "#batch_destroy" do

      it "deletes the cart item if it hasn't been downloaded" do
        expect{
          process :batch_destroy, method: :delete, params: {:batch_document_ids => [cartItem1.id]}
        }.to change{CartItem.count}.by(-1)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been downloaded" do
        expect{
          process :batch_destroy, method: :delete, params: {:batch_document_ids => [cartItem4.id]}
        }.to change{CartItem.count}.by(0)
        delete :batch_destroy, params: {:batch_document_ids => [cartItem4.id]}
        cartItem4.reload
        expect(cartItem4.in_cart).to eq(false)
      end

      it "returns flash message 'Item Removed from Cart'" do
        delete :batch_destroy, params: {:batch_document_ids => [cartItem1.id]}
        expect(response.flash[:notice]).to eq('1 Item Removed from Cart')
      end
    end
  end

  describe "#batch_create" do
    context "the work is not already in the cart" do
      let(:work5) { Media.new(id: "eee", title: ["Test Work Title"]) }
      let(:work6) { Media.new(id: "fff", title: ["Test Work Title"]) }

      before do
        allow(Media).to receive(:find).with(cartItem5.work_id).and_return(work5)
        allow(Media).to receive(:find).with(cartItem6.work_id).and_return(work6)
      end

      it "creates new cart items" do
        expect{
          process :batch_create, method: :get, params: {:batch_document_ids => [cartItem5.id, cartItem6.id]}
        }.to change{CartItem.count}.by(2)
      end

      it "displays a flash message" do
        get :batch_create, params: {:batch_document_ids => [cartItem5.id, cartItem6.id]}
        expect(response.flash[:notice]).to eq("2 Items Added to Cart")
      end
    end

    context "the work is already in the cart" do
      let(:cartItem7)     { CartItem.create( media_cart_id: media_cart.id, work_id: "aaa", in_cart: false, date_downloaded: Time.current) }
      let(:cartItem8)     { CartItem.create( media_cart_id: media_cart.id, work_id: "bbb", in_cart: false, date_downloaded: Time.current) }
      let(:work2) { Media.new(id: "bbb", title: ["Test Work Title"]) }

      before do
        allow(Media).to receive(:find).with(cartItem7.work_id).and_return(work)
        allow(Media).to receive(:find).with(cartItem8.work_id).and_return(work2)
      end

      it "does not create new cart items" do
        expect{
          process :batch_create, method: :get, params: {:batch_document_ids => [cartItem7.id, cartItem8.id]}
        }.to change{CartItem.count}.by(0)
      end

      it "displays a flash message" do
        get :batch_create, params: {:batch_document_ids => [cartItem7.id, cartItem8.id]}
        expect(response.flash[:notice]).to eq("0 Items Added to Cart; 2 Items: Maaa: Test Media Work, Test Work Title Already in Your Cart.")
      end
    end
  end

  describe '#download' do
    context "the user uses batch-select to select several cart items" do
      before do
        get :download, params: { batch_document_ids: [cartItem1.id, cartItem2.id] }
      end
      it "sets the items' date_downloaded" do
        [cartItem1, cartItem2].each(&:reload)
        expect(cartItem1.date_downloaded.to_date).to eq(Time.now.to_date)
        expect(cartItem2.date_downloaded.to_date).to eq(Time.now.to_date)
      end
      it "does not change the date downloaded for unselected items in the cart" do
        [cartItem3, cartItem4].each(&:reload)
        expect(cartItem3.date_downloaded).to eq(nil)
      end
      it "redirects to media/#zip with the work ids as params" do
        work_ids = [cartItem1.work_id, cartItem2.work_id]
        redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
        expect(response).to redirect_to %r(\Ahttp://test.host/concern/media/zip?)
        expect(redirect_params["ids[]"]).to match_array(work_ids)
      end
    end
    context "the user clicks the 'download all' button" do
      before do
        get :download, params: {}
      end
      it "sets the date_downloaded for all the items in the user's cart" do
        [cartItem1, cartItem2, cartItem3, cartItem4].each(&:reload)
        expect(cartItem1.date_downloaded.to_date).to eq(Time.now.to_date)
        expect(cartItem2.date_downloaded.to_date).to eq(Time.now.to_date)
        expect(cartItem3.date_downloaded.to_date).to eq(Time.now.to_date)
        expect(cartItem4.date_downloaded.to_date).to eq(Time.now.to_date)
      end
      it "redirects to media/#zip with the work ids as params" do
        work_ids = [cartItem1.work_id, cartItem2.work_id, cartItem3.work_id, cartItem4.work_id]
        redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
        expect(response).to redirect_to %r(\Ahttp://test.host/concern/media/zip?)
        expect(redirect_params["ids[]"]).to match_array(work_ids)
      end
    end
  end
end
