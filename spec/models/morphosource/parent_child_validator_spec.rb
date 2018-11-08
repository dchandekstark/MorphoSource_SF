require 'rails_helper'

  RSpec.describe Morphosource::ParentChildValidator do

    let(:record) { Media.new( { title: ["Sample Media"] } ) }
    let(:valid_child) { ProcessingEvent.new( { title: ["Sample Processing Event"] } ) }
    let(:invalid_child) { Institution.new( { title: ["Sample Institution"]} )}
    let(:invalid_child2) { BiologicalSpecimen.new( { title: ["Sample BiologicalSpecimen"] } ) }
    let(:valid_parent) { ImagingEvent.new( { title: ["Sample Imaging Event"]} )}
    let(:invalid_parent) { Attachment.new( { title: ["Sample Attachment"]} )}
    let(:invalid_parent2) { CulturalHeritageObject.new( { title: ["Sample CHO"]} )}


    context "an invalid child is added" do

      before do
        record.ordered_members << invalid_child
        subject.validate(record)
      end

      it "raises an error" do
        expect( record.errors[:works] ).to match_array( ['valid children for Media do not include Institution.'] )
      end
    end

    context "an invalid parent is added" do

      before do
        invalid_parent.ordered_members << record
        subject.validate(invalid_parent)
      end

      it "raises an error" do
        expect( invalid_parent.errors[:works] ).to match_array( ["valid children for Attachment do not include Media."] )
      end
    end

    context "valid parent and child are added" do
      before do
        record.ordered_members << valid_child
        valid_parent.ordered_members << record

        subject.validate(record)
        subject.validate(valid_parent)
      end

      it "does not raise errors" do
        expect( record.errors[:works] ).to match_array( [] )
        expect( valid_parent.errors[:works] ).to match_array( [] )
      end
    end

    context "two invalid parents and two invalid children are added" do
      before do
        record.ordered_members << invalid_child
        record.ordered_members << invalid_child2
        invalid_parent.ordered_members << record
        invalid_parent2.ordered_members << record

        subject.validate(record)
        subject.validate(invalid_parent)
        subject.validate(invalid_parent2)
      end

      it "raises errors" do
        expect( record.errors[:works][0] ).to include("valid children for Media do not include", "BiologicalSpecimen", "Institution" )
        expect( invalid_parent.errors[:works] ).to match_array( ["valid children for Attachment do not include Media."])
        expect( invalid_parent2.errors[:works] ).to match_array( ["valid children for CulturalHeritageObject do not include Media."])
      end
    end

end
