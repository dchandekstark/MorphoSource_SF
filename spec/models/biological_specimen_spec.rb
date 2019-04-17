# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
require 'rails_helper'

RSpec.describe BiologicalSpecimen do

  describe 'metadata' do

    it_behaves_like 'a Morphosource work'

    it_behaves_like 'a work with physical object metadata'

    it 'has biological specimen descriptive metadata' do
      expect(subject.attributes.keys).to include('idigbio_recordset_id', 'idigbio_uuid', 'is_type_specimen',
                                                 'occurrence_id', 'sex')
    end
  end

  describe "valid work relationships" do

    it "has only Institution as a valid parent" do
      expect(subject.valid_parent_concerns).to match_array([Institution, Taxonomy])
    end

    it "has ImagingEvent and Attachment as valid child concerns" do
      expect(subject.valid_child_concerns).to match_array([ImagingEvent, Attachment])
    end

  end

  describe "instance" do
    subject { BiologicalSpecimen.create(title: ["BSO title"], vouchered: ["Yes"]) }

    describe "valid work relationships" do

      it "has Institution and Taxonomy as valid parents" do
        expect(subject.valid_parent_concerns).to match_array([Institution, Taxonomy])
      end

      it "has ImagingEvent and Attachment as valid child concerns" do
        expect(subject.valid_child_concerns).to match_array([ImagingEvent, Attachment])
      end

    end

    describe "taxonomy methods" do
      let (:taxonomy1)  { Taxonomy.create(id: "1", title: ["taxonomy1 title"], trusted: ["Yes"]) }
      let (:taxonomy2)  { Taxonomy.create(id: "2", title: ["taxonomy2 title"], trusted: ["Yes"]) }
      let (:taxonomy3)  { Taxonomy.create(id: "3", title: ["taxonomy3 title"], trusted: ["No"]) }
      let (:institution){ Institution.create(id: "4", title: ["institution title"]) }
      let (:parents) {[taxonomy1, taxonomy2, taxonomy3, institution]}

      before do
        parents.each do |parent|
          parent.members << subject
          parent.save
        end
        subject.canonical_taxonomy = [taxonomy1.id]
      end

      describe "#taxonomies" do
        it 'returns only its parents that are taxonomies' do
          expect(subject.taxonomies).to match_array([taxonomy1, taxonomy2, taxonomy3])
        end
      end

      describe "#canonical_taxonomy_object" do
        it 'returns the Taxonomy for its canonical_taxonomy' do
          expect(subject.canonical_taxonomy_object).to eq(taxonomy1)
        end
      end

      describe "#canonical_taxonomy_title" do
        it 'returns the title for its canonical_taxonomy' do
          expect(subject.canonical_taxonomy_title).to eq(taxonomy1.title.first)
        end
      end

      describe "#other_taxonomies" do
        it 'returns all parent taxonomies except the canonical taxonomy' do
          expect(subject.other_taxonomies).to match_array([taxonomy2, taxonomy3])
        end
      end

      describe "#trusted_taxonomies" do
        it 'returns all institutional taxonomies except the canonical taxonomy' do
          expect(subject.trusted_taxonomies).to match_array([taxonomy2])
        end
      end

      describe "#user_taxonomies" do
        before do
          taxonomy1.trusted = ["No"]
        end
        it 'returns all taxonomies that are not trusted except the canonical taxonomy' do
          expect(subject.user_taxonomies).to match_array([taxonomy3])
        end
      end
    end
  end
end
