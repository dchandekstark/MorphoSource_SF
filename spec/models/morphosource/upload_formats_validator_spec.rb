require 'rails_helper'

  RSpec.describe Morphosource::UploadFormatsValidator do

    let(:record)        { Media.new( { title: ["Sample Media"], media_type: ["Image"] } ) }
    let(:file_set_1)    { FileSet.new }
    let(:file_set_2)    { FileSet.new }
    let(:file_set_3)    { FileSet.new }

    context "the record has valid files attached" do

      before do
        file_set_1.label = "ImageFile.jpg"
        file_set_2.label = "ImageFile.png"
        file_set_3.label = "ImageFile.tif"

        record.ordered_members << file_set_1 << file_set_2 << file_set_3
        subject.validate(record)
      end

      it "has no base errors" do
        expect(record.errors[:base]).to match_array( [] )
      end

    end

    context "the record has invalid files attached" do

      before do
        file_set_1.label = "VideoFile.avi"
        file_set_2.label = "VideoFile.mov"
        file_set_3.label = "VideoFile.mpg"

        record.ordered_members << file_set_1 << file_set_2 << file_set_3
        subject.validate(record)
      end

      it "has a base error listing the invalid files" do

        expect(record.errors[:base][0]).to include("VideoFile.avi", "VideoFile.mov", "VideoFile.mpg" )

      end
    end

    context "the record has a mix of valid and invalid files attached" do

      before do

        file_set_1.label = "ImageFile.jpg"
        file_set_2.label = "MeshFile.gltf"
        file_set_3.label = "MeshFile.obj"

        record.ordered_members << file_set_1 << file_set_2 << file_set_3
        subject.validate(record)
      end

      it "has a base error listing the invalid files" do

        expect(record.errors[:base][0]).to include( "MeshFile.gltf", "MeshFile.obj" )

      end
    end
  end
