# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'

RSpec.describe Media do

  it 'has a title' do
    subject.title = ['foo']
    expect(subject.title).to eq ['foo']
  end

end
