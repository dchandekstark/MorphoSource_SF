# Generated via
#  `rails generate hyrax:work PhysicalObject`
require 'rails_helper'

RSpec.describe PhysicalObject do

  describe "metadata" do
    it "has descriptive metadata" do

      expect(subject).to respond_to(:bibliographic_citation)
      expect(subject).to respond_to(:catalog_number)
      expect(subject).to respond_to(:collection_code)
      expect(subject).to respond_to(:based_near)
      # expect(subject).to respond_to(:current_location)
      expect(subject).to respond_to(:date_created)
      expect(subject).to respond_to(:description)
      expect(subject).to respond_to(:identifier)
      expect(subject).to respond_to(:institution)
      expect(subject).to respond_to(:latitude)
      expect(subject).to respond_to(:longitude)
      expect(subject).to respond_to(:numeric_time)
      expect(subject).to respond_to(:original_location)
      expect(subject).to respond_to(:periodic_time)
      expect(subject).to respond_to(:physical_object_type)
      expect(subject).to respond_to(:publisher)
      expect(subject).to respond_to(:related_url)
      expect(subject).to respond_to(:vouchered)

      #Biological only
      expect(subject).to respond_to(:idigbio_recordset_id)
      expect(subject).to respond_to(:idigbio_uuid)
      expect(subject).to respond_to(:is_type_specimen)
      expect(subject).to respond_to(:occurrence_id)
      expect(subject).to respond_to(:sex)

      #CHOs only
      expect(subject).to respond_to(:title)
      expect(subject).to respond_to(:contributor)
      expect(subject).to respond_to(:creator)
      expect(subject).to respond_to(:material)
      expect(subject).to respond_to(:cho_type)

    end
  end

end
