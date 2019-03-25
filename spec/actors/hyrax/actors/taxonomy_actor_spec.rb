# Generated via
#  `rails generate hyrax:work Taxonomy`
require 'rails_helper'

RSpec.describe Hyrax::Actors::TaxonomyActor do

  let(:next_actor) { double(create: true, update: true) }
  subject { described_class.new(next_actor) }
  let(:work) { Taxonomy.new }
  let(:ability) { Ability.new(User.new(id: 5)) }
  let(:attrs) { { "taxonomy_domain" => ["Domain"],
                  "taxonomy_kingdom" => ["Kingdom"],
                  "taxonomy_phylum" => ["Phylum"],
                  "taxonomy_superclass" => [],
                  "taxonomy_class" => ["Class"],
                  "taxonomy_subclass" => [],
                  "taxonomy_superorder" => [],
                  "taxonomy_order" => ["Order"],
                  "taxonomy_suborder" => [],
                  "taxonomy_superfamily" => [],
                  "taxonomy_family" => ["Family"],
                  "taxonomy_subfamily" => [],
                  "taxonomy_tribe" => [],
                  "taxonomy_genus" => ["Genus"],
                  "taxonomy_subgenus" => ["Subgenus"],
                  "taxonomy_species" => ["Species"],
                  "taxonomy_subspecies" => [],
                  "source" => [] } }
  let(:env) { Hyrax::Actors::Environment.new(work, ability, attrs) }

  describe '#create' do
    before do
      allow(subject).to receive(:save) { true }
      allow(subject).to receive(:run_callbacks) { true }
    end

    it 'changes the title attribute' do
      expect { subject.create(env) }.to change{env.attributes['title']}.to([ "Domain > Kingdom > Phylum > Class > Order > Family > Genus > Subgenus > Species" ])
    end

    context 'user enters a source' do
      before do
        env.attributes['source'] = ["test source"]
      end
      it 'does not change the source attribute' do
        expect { subject.create(env) }.to_not change{env.attributes['source']}
      end
    end

    context 'user does not enter a source' do
      before do
        env.attributes['source'] = []
      end
      it "changes the source to 'user-provided'" do
        expect { subject.create(env) }.to change{env.attributes['source']}.to (["user-provided"])
      end
    end

    describe '#update' do
      before do
        env.curation_concern.title = ["Previous title"]
        env.curation_concern.source = ["Previous source"]
        allow(subject).to receive(:save) { true }
        allow(subject).to receive(:run_callbacks) { true }
      end

      it 'changes the title attribute' do
        expect { subject.update(env) }.to change{env.attributes['title']}.to([ "Domain > Kingdom > Phylum > Class > Order > Family > Genus > Subgenus > Species" ])
      end

      context 'user enters a source' do
        before do
          env.attributes['source'] = ["test source"]
        end
        it 'does not change the source attribute' do
          expect { subject.update(env) }.to_not change{env.attributes['source']}
        end
      end

      context 'user does not enter a source' do
        before do
          env.attributes['source'] = []
        end
        it "changes the source to 'user-provided'" do
          expect { subject.update(env) }.to change{env.attributes['source']}.to (["user-provided"])
        end
      end
    end
  end


end
