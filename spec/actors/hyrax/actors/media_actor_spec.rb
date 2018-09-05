# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'

RSpec.describe Hyrax::Actors::MediaActor do

  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  let(:user) { FactoryBot.build(:user) }
  let(:ability) { Ability.new(user) }
  let(:media) { FactoryBot.create(:media)}
  let(:env) { Hyrax::Actors::Environment.new(media, ability, attributes) }

  let(:terminator) { Hyrax::Actors::Terminator.new }

  describe '#create' do

    before do
      middleware.create(env)
    end

    describe 'scale bar' do

      let(:attributes) { { title: ["example media title"],
      scale_bar_target_type: ["example type"], scale_bar_distance: ["example distance"],
      scale_bar_units: ["example units"], scale_bar: [""]} }

      it 'concatenates type, distance, and units' do
        expect(env.attributes[:scale_bar]).to contain_exactly("Type: example type, Distance: example distance, Units: example units")
      end
    end
  end

  describe '#update' do

    before do
      middleware.update(env)
    end

    describe 'scale bar' do

      let(:attributes) { { title: ["example new media title"],
      scale_bar_target_type: ["example new type"], scale_bar_distance: ["example new distance"],
      scale_bar_units: ["example new units"], scale_bar: [""]} }

      it 'concatenates updated type, distance, and units' do
        expect(env.attributes[:scale_bar]).to contain_exactly("Type: example new type, Distance: example new distance, Units: example new units")
      end
    end
  end

end
