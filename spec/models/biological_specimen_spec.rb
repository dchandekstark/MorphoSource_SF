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
      expect(subject.valid_parent_concerns).to eq([Institution])
    end

    it "has ImagingEvent and Attachment as valid child concerns" do
      expect(subject.valid_child_concerns).to eq([ImagingEvent, Attachment])
    end
    
  end

  describe "instance" do
    subject { BiologicalSpecimen.new({
        title: ['Test Institution']
      })
    }

    describe "valid work relationships" do

      it "has only Institution as a valid parent" do
        expect(subject.valid_parent_concerns).to eq([Institution])
      end

      it "has ImagingEvent and Attachment as valid child concerns" do
        expect(subject.valid_child_concerns).to eq([ImagingEvent, Attachment])
      end

    end

  end

end
