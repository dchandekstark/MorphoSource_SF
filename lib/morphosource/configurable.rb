module Morphosource
  module Configurable
    extend ActiveSupport::Concern

    included do

      # Geonames user account
      mattr_accessor :geonames_user do
        ENV["GEONAMES_USER"] || "NOT_SET"
      end

      # Allowed formats for uploads based on selected Media type
      MEDIA_FORMATS = {
        'Image' => :image_formats,
        'Video' => :video_formats,
        'CTImageStack' => :ct_formats,
        'PhotogrammetryImageStack' => :photogrammetry_formats,
        'Mesh' => :mesh_formats,
        'Other' => :other_formats
      }

      mattr_accessor :all_formats do
        [".avi", ".bmp", ".dcm", ".dicom", ".gif", ".gltf", ".jp2", ".jpeg", ".jpg", ".m4v", ".mov", ".mp4", ".mpg", ".mpeg", ".mtl", ".obj", ".pdf", ".ply", ".png", ".stl", ".tif", ".tiff", ".wmv", ".wrl", ".x3d", ".zip"]
      end

      mattr_accessor :image_formats do
        [".bmp", ".dcm", ".dicom", ".gif", ".jp2", ".jpeg", ".jpg", ".png", ".tif", ".tiff"]
      end

      mattr_accessor :video_formats do
        [".avi", ".m4v", ".mov", ".mp4", ".mpg", ".mpeg", ".wmv"]
      end

      mattr_accessor :ct_formats do
        [".zip"]
      end

      mattr_accessor :photogrammetry_formats do
        [".zip"]
      end

      mattr_accessor :mesh_formats do
        [".bmp", ".dcm", ".dicom", ".gif", ".gltf", ".jp2", ".jpeg", ".jpg", ".mtl", ".obj", ".obj", ".ply", ".png", ".stl", ".tif", ".tiff", ".wrl", ".x3d", ".zip"]
      end

      # right now same as all formats
      mattr_accessor :other_formats do
        self.all_formats
      end

    end

  end
end
