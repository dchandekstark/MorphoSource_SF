require 'rails_helper'

RSpec.describe ::SolrDocument, type: :model do
	let(:document) { described_class.new(attributes) }
	let(:attributes) { {} }

	describe "#file_ext" do
		context "when title is a filename" do
			let(:attributes) { { title_tesim: 'test.txt'} }

			it "returns an extension" do
				expect(document.file_ext).to eq '.txt'
			end
		end

		context "when title is not a filename" do
			let(:attributes) { { title_tesim: 'notafilename'} }

			it "does not return an extension" do
				expect(document.file_ext).to eq ''
			end
		end
	end

	describe "#mesh?" do
		context "when title is a mesh filename" do
			mesh_filenames = ['test.ply', 'test.stl', 'test.obj', 'test.gltf']
			mesh_filenames.each do |f|
				describe "#{f}" do
					let!(:attributes) { { title_tesim: f} }

					it "returns true" do
						expect(document.mesh?).to be true
					end
				end		
			end
		end

		context "when title is a non-mesh filename" do
			let(:attributes) { { title_tesim: 'test.txt'} }

			it "returns false" do
				expect(document.mesh?).to be false
			end
		end

		context "when title is not a filename" do
			let(:attributes) { { title_tesim: 'notafilename'} }

			it "returns false" do
				expect(document.mesh?).to be false
			end

		end
	end

	describe "#mesh_mime_type" do
		context "when title is a mesh filename" do
			mesh_mime_types = { "test.ply" => "application/ply", 
                        	"test.stl" => "application/sla", 
                        	"test.obj" => "text/plain", 
                        	"test.gltf" => "model/gltf+json" }

			mesh_mime_types.each do |f, mime_type|
				describe "#{f}" do
					let!(:attributes) { { title_tesim: f} }

					it "returns a valid mime_type" do
						expect(document.mesh_mime_type).to eq mime_type
					end
				end
			end
		end

		context "when title is a non-mesh filename" do
			let(:attributes) { { title_tesim: 'test.txt'} }

			it "returns a falsey value" do
				expect(document.mesh_mime_type).to be_falsey
			end
		end

		context "when title is not a filename" do
			let(:attributes) { { title_tesim: 'notafilename'} }

			it "returns a falsey value" do
				expect(document.mesh_mime_type).to be_falsey
			end
		end
	end
end