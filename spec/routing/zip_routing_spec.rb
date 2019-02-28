require 'rails_helper'

RSpec.describe 'zip routing', type: :routing do

  it 'has a new route' do
    route = { controller: 'hyrax/media', action: 'zip' }
    expect(:get => '/concern/media/zip').to route_to(route)

    route = { controller: 'hyrax/file_sets', action: 'zip' }
    expect(:get => '/concern/file_sets/zip').to route_to(route)
  end

end
