require 'rails_helper'

RSpec.describe 'cart items routing', type: :routing do

  it 'has a route for my downloads page' do
    route = { controller: 'morphosource/my/cart_items', action: 'previous_downloads' }
    expect(:get => 'dashboard/my/downloads').to route_to(route)
  end

  it 'has a route for my media cart page' do
    route = { controller: 'morphosource/my/cart_items', action: 'media_cart' }
    expect(:get => 'dashboard/my/cart').to route_to(route)
  end

  it 'has a route to add a work to the media cart' do
    route = { controller: 'morphosource/my/cart_items', action: 'create' }
    expect(:post => 'add_to_cart').to route_to(route)
  end

  it 'has a route to copy items from the downloads page to the shopping cart' do
    route = { controller: 'morphosource/my/cart_items', action: 'batch_create' }
    expect(:post => 'batch_create_items').to route_to(route)
  end

  it 'has a route to batch destroy cart items' do
    route = { controller: 'morphosource/my/cart_items', action: 'batch_destroy' }
    expect(:delete => '/cart_items').to route_to(route)
  end

  it 'has a route to download cart items' do
    route = { controller: 'morphosource/my/cart_items', action: 'download' }
    expect(:get => 'download_items').to route_to(route)
  end

end
