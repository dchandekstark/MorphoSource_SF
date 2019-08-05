require 'rails_helper'

RSpec.describe Morphosource::CartItemHelper, type: :helper do
  let(:work)  { double('work', id: 'www', depositor: 'test@test.com')}
  let(:item)  { CartItem.create( id: 'aaa', media_cart_id: 'bbb', work_id: work.id)}

  before do
    allow(Media).to receive(:find).with(item.work_id).and_return(work)
  end

  describe '#item_status_label and #item_action_button' do

    context 'the item is canceled' do
      let(:label_content) do
        %(<span class=\"label label-danger\" style=\"background-color: gray;\">Canceled</span>)
      end
      let(:button_content) do
        %(<a class=\"btn btn-info\" style=\"\" rel=\"nofollow\" data-method=\"put\" href=\"/request_item?item_id=#{item.id}\">Request Download</a>)
      end
      before do
        item.date_requested = Date.yesterday
        item.date_canceled = Date.today
      end

      it 'creates a "Canceled" label' do
        expect(item_status_label(item)).to eq(label_content)
      end

      it 'creates a "Request Download" button' do
        expect(item_action_button(item)).to eq(button_content)
      end

    end

    context 'the request is denied' do
      let(:label_content) do
        %(<span class=\"label label-danger\" style=\"\">Denied</span>)
      end
      let(:button_content) do
        %(<a class=\"btn btn-danger\" style=\"\" rel=\"nofollow\" data-method=\"delete\" href=\"/remove_from_cart?item_id=#{item.id}\">Remove from Cart</a>)
      end
      before do
        item.date_requested = Date.yesterday
        item.date_denied = Date.today
      end

      it 'creates a "Denied" label' do
        expect(item_status_label(item)).to eq(label_content)
      end
      it 'creates a "Remove from Cart" button' do
        expect(item_action_button(item)).to eq(button_content)
      end
    end

    context 'the request approval is expired' do
      let(:label_content) do
        %(<span class=\"label label-warning\" style=\"background-color: orange;\">Expired</span>)
      end
      let(:button_content) do
        %(<a class=\"btn btn-primary\" style=\"\" data-method=\"get\" href=\"/request_again?item_id=#{item.id}\">Request Again</a>)
      end
      before do
        item.date_requested = Date.yesterday
        item.date_approved = Date.yesterday
        item.date_expired = Date.yesterday
      end

      it 'creates an "Expired" label' do
        expect(item_status_label(item)).to eq(label_content)
      end
      it 'creates a "Request Again" button' do
        expect(item_action_button(item)).to eq(button_content)
      end
    end

    context 'the request is approved' do
      let(:label_content) do
        %(<span class=\"label label-success\" style=\"\">Approved</span>)
      end
      before do
        item.date_requested = Date.yesterday
        item.date_approved = Date.yesterday
        item.date_expired = Date.tomorrow
      end

      it 'creates an "Approved" label' do
        expect(item_status_label(item)).to eq(label_content)
      end
    end

    context 'the item status is requested' do
      let(:label_content) do
        %(<span class=\"label label-primary\" style=\"\">Requested</span>)
      end
      let(:button_content) do
        %(<a class=\"btn btn-danger\" style=\"background-color: gray;\" rel=\"nofollow\" data-method=\"put\" href=\"/cancel_request?item_id=#{item.id}\">Cancel Request</a>)
      end
      before do
        item.date_requested = Date.today
      end

      it 'creates a "Requested" label' do
        expect(item_status_label(item)).to eq(label_content)
      end
      it 'creates a "Cancel Request" button' do
        expect(item_action_button(item)).to eq(button_content)
      end
    end

    context 'the item is not requested' do
      let(:label_content) do
        %(<span class=\"label label-info\" style=\"background-color: teal;\">Not Requested</span>)
      end
      let(:button_content) do
        %(<a class=\"btn btn-info\" style=\"\" rel=\"nofollow\" data-method=\"put\" href=\"/request_item?item_id=#{item.id}\">Request Download</a>)
      end

      it 'creates a "Not Requested" label' do
        expect(item_status_label(item)).to eq(label_content)
      end
      it 'creates a "Request Download" button' do
        expect(item_action_button(item)).to eq(button_content)
      end
    end

    context 'the item is downloadable' do
      let(:button_content) do
        %(<a class=\"btn btn-info\" style=\"\" data-method=\"get\" href=\"/download_items?item_id=#{item.id}\">Download Item</a>)
      end
      before do
        item.restricted = false
      end

      it 'creates a "Download Item" button' do
        expect(item_action_button(item)).to eq(button_content)
      end

    end
  end
end
