require 'zip'

module Morphosource::Derivatives::Processors
	class TimeoutError < Hydra::Derivatives::TimeoutError
  	end

	class CTImageSeries < Hydra::Derivatives::Processors::Processor
		attr_accessor :tmp_dir_path, :input_path, :jpeg_path, :out_path, :manifest_path
    attr_accessor :x, :y, :z, :linear_scale_factor
    attr_accessor :x_spacing, :y_spacing, :z_spacing, :slice_thickness

		class_attribute :timeout

    def self.acceptable_image_formats
      ['.dcm', '.tiff', '.tif', '.bmp']
    end

		def process
			timeout ? process_with_timeout : create_ct_image_series_derivative
		end

		def process_with_timeout
			Timeout.timeout(timeout) { create_ct_image_series_derivative }
		rescue Timeout::Error
			raise Morphosource::Derivatives::Processors::TimeoutError, "Unable to process CT Image Series derivative\nThe command took longer than #{timeout} seconds to execute"
		end

		protected

		def create_ct_image_series_derivative
			@tmp_dir_path = Rails.root.join('tmp', SecureRandom.uuid)
			@input_path = File.join(tmp_dir_path, 'input')
			@jpeg_path = File.join(tmp_dir_path, 'jpeg')
			@output_path = File.join(tmp_dir_path, 'output')

      @x = nil
      @y = nil
      @z = nil

      @x_spacing = directives.fetch(:x_spacing, 0).presence || 0
      @y_spacing = directives.fetch(:y_spacing, 0).presence || 0
      @z_spacing = directives.fetch(:z_spacing, 0).presence || 0
      @slice_thickness = directives.fetch(:slice_thickness, 0).presence || 0

			# todo: locate images in zip

			# unzip zip archive to input_dir
			import_image_archive

			# todo: have a step to convert whatever to tiff pre-imagej

			# use imagej to convert input_dir whatever to jpeg_dir jpegs
			img_to_jpeg

			# use img2dcm to convert jpeg_dir jpegs to output_dir dcms
			jpeg_to_dcm

			# generate manifest json
			@manifest_path = gen_manifest

			# place files
			write_files

			cleanup_tmp_files
		end

#a=[{ 'foo'=>0,'bar'=>1 },
# { 'foo'=>0,'bar'=>2 },
#  ... ]

# a.sort { |a, b| [a['foo'], a['bar']] <=> [b['foo'], b['bar']] }

    # {}[loc] = { loc: XXX, ext: XXX, files: [] }

    def locate_images
      img_locs = {}
      Zip::File.open(source_path) do |zip_file|
        zip_file.each do |f|
          ext = File.extname(f)
          if self.acceptable_image_formats.include? ext
            loc = File.basepath(f)
            if !img_locs.key?(loc)
              img_locs[loc] = {
                loc: loc, 
                ext: ext,
                files: []
              }
            end 
            img_locs[loc][:files] << f
          end
        end
      end

      v = img_locs.values
      v.sort { |a, b| [] <=> [] }
    end

    def import_image_archive(format='.dcm')
      x, y, z = extract_file_and_metadata(format=format)
      if x.uniq.len != 1 || y.uniq.len != 1 || z == 0
        cleanup_tmp_files
        # error out, no images or different kinds of images
      else
        @x = x.first
        @y = y.first
        @z = z
        @linear_scale_factor = linear_scale_factory
      end
    end

    def extract_file_and_metadata(format='.dcm')
      x = []
      y = []
      z = 0
      Zip::File.open(source_path) do |zip_file|
        zip_file.each do |f|
          next unless f.name == format
          x_dim, y_dim = image_dims(f.get_input_stream)
          x << x_dim if x_dim
          y << y_dim if y_dim
          z += 1 if x_dim && y_dim
          f.extract(File.join(input_path, f.name))
        end
      end
      return x, y, z
    end

    def image_dims(io_stream)
      img = Minimagick::Image.read(io_stream)
      if img.valid?
        return img.width, img.height
      end
    end

    def linear_scale_factor
      ( (300.0**3) / (x.to_f * y.to_f * z.to_f) )**( 1.0/3.0 )
    end

		def img_to_jpeg
      imagej = Morphsource::Derivatives::ImageJ.new(imagej_macro)
      imagej.call
		end

    def imagej_macro
      erb_src = 'imagej_macro.txt.erb'
      txt_dst = File.join(tmp_dir_path, File.basename(erb_src, '.erb'))
      File.open(txt_dst, 'w') do |f|
        f.write(ERB.new(File.read(erb_src)).result())
      end
      txt_dst
    end

		def jpeg_to_dcm
      new_x, new_y, new_z, new_slice_thickness = new_spacing
      img2dcm = Morphosource::Derivatives::Img2dcm.new(jpeg_path, output_path, new_x, new_y, new_z, new_slice_thickness)
      img2dcm.call
		end

    def new_spacing
      # height and width
      new_x = ( x.to_f * x_spacing.to_f ) / new_dim(x)
      new_y = ( y.to_f * y_spacing.to_f ) / new_dim(y)

      # depth 
      z_total = ( z_spacing.to_f * (z.to_f - 1.0) ) + slice_thickness
      new_slice_thickness = ( slice_thickness.to_f * z.to_f) / new_dim(z)
      new_z = ( z_total  - new_slice_thickness ) / ( new_dim(z) - 1 ) 

      return new_x, new_y, new_z, new_slice_thickness
    end

    def new_dim(var)
      ( var.to_f * linear_scale_factor ).to_i
    end

		def gen_manifest
      erb_src = 'manifest.json.erb'
      txt_dst = File.join(tmp_dir_path, File.basename(erb_src, '.erb'))
      File.open(txt_dst, 'w') do |f|
        f.write(ERB.new(File.read(erb_src)).result())
      end
      txt_dst
		end

    def dicom_series
      (Dir.entries(output_path).map { |f| '"'+f+'"' unless File.directory?(f) }).join(',')
    end

    def base_derivative_path
      # todo: add derived path here
      'https://testhost/derivatives/aa/bb/cc/dd/e/'
    end

    def write_files
      # write manifest file
      output_file_service.call(manifest_path, directives)

      # write images
      Dir(output_path).foreach do |f|
        next if f == '.' or f == '..'
        f_directives = directives.merge(
          { url: ct_series_image_url(f) })
        output_file_service.call(f, f_directives)
      end
    end

		def cleanup_tmp_files
			FileUtils.remove_dir tmp_dir_path
		end
	end
end
