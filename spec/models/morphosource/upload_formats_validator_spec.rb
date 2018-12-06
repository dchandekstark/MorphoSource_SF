require 'rails_helper'

  RSpec.describe Morphosource::UploadFormatsValidator do
    let(:user)         { FactoryBot.create(:user) }
    let(:record)       { Media.new( { title: ["Sample Media"] } ) }

    let(:file_path1)   { File.join(fixture_path, '/images/duke.png') }
    let(:file1)        { fixture_file_upload(file_path1, 'image/png') }
    let(:local_file1)  { File.open(file_path1) }

    let(:file_path2)   { File.join(fixture_path, '/images/ms.jpg') }
    let(:file2)        { fixture_file_upload(file_path2, 'image/jpg') }
    let(:local_file2)  { File.open(file_path2) }

    let(:file_path3)   { File.join(fixture_path, '/ms.zip') }
    let(:file3)        { fixture_file_upload(file_path3, 'application/zip') }
    let(:local_file3)  { File.open(file_path3) }

    let(:file_set_1)   { FileSet.new }
    let(:file_set_2)   { FileSet.new }
    let(:file_set_3)   { FileSet.new }

    before do
      Hydra::Works::AddFileToFileSet.call(file_set_1, local_file1, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_2, local_file2, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_3, local_file3, :original_file, versioning: true)
    end

    context "the record has files with valid formats attached" do
      before do
        record.media_type = ["Image"]
        record.ordered_members << file_set_1 << file_set_2
        subject.validate(record)
      end
      it "has no base errors" do
        expect(record.errors[:base]).to match_array( [] )
      end
    end

    context "the record has files with invalid formats attached" do

      before do
        record.media_type = ["Video"]
        record.ordered_members << file_set_1 << file_set_2 << file_set_3
        subject.validate(record)
      end

      it "has a base error listing the invalid files" do
        expect(record.errors[:base][0]).to include("duke.png", "ms.jpg", "ms.zip" )
      end
    end

    context "the record has a mix of valid and invalid formats attached" do

      before do
        record.media_type = ["Image"]
        record.ordered_members << file_set_1 << file_set_2 << file_set_3
        subject.validate(record)
      end

      it "has a base error listing the invalid files" do
        expect(record.errors[:base][0]).to include( "ms.zip" )
      end
    end
  end
