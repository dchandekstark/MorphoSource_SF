require 'fileutils'
require 'zip'

module Morphosource::Derivatives::Processors
	class TimeoutError < Hydra::Derivatives::TimeoutError
  	end

	class CTImageSeries < Hydra::Derivatives::Processors::Processor
		attr_accessor :tmp_dir_path, :img_coll, :ext, :input_path, :jpeg_path, :output_path, :manifest_path
    attr_accessor :x, :y, :z, :linear_scale_factor
    attr_accessor :x_spacing, :y_spacing, :z_spacing, :slice_thickness

		class_attribute :timeout

    def acceptable_image_formats
      ['.dcm', '.dicom', '.tiff', '.tif', '.bmp', '.png', '.jpeg', '.jpg']
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
        Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path
    		@input_path = File.join(tmp_dir_path, 'input')
        Dir.mkdir input_path unless File.exist? input_path
    		@jpeg_path = File.join(tmp_dir_path, 'jpeg')
        Dir.mkdir jpeg_path unless File.exist? jpeg_path
    		@output_path = File.join(tmp_dir_path, 'output')
        Dir.mkdir output_path unless File.exist? output_path

        
        @x_spacing = directives.fetch(:x_spacing, 1).presence || 1
        @y_spacing = directives.fetch(:y_spacing, 1).presence || 1
        @z_spacing = directives.fetch(:z_spacing, 0).presence
        @slice_thickness = directives.fetch(:slice_thickness, 0).presence || 0
        @z_spacing = 1 if z_spacing == 0 && slice_thickness == 0
        # todo: grab image resolutions from dicom if possible? (or should that be done via work characterization?)

    		# todo: locate images in zip
        locate_images
        if !img_coll
          return
        end 
        
    		# unzip zip archive to input_dir
    		import_image_archive

        uncompress_dcm if ext == '.dcm'

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
      # get all image files and locations in zip
      img_locs = {}
      Zip::File.open(source_path) do |zip_file|
        zip_file.each do |f|
          ext = File.extname(f.name).downcase
          if acceptable_image_formats.include? ext
            loc = File.dirname(f.name)
            if !img_locs.key?(ext)
              img_locs[ext] = {}
            end
            if !img_locs[ext].key?(loc)
              img_locs[ext][loc] = []
            end 
            img_locs[ext][loc] << f.name
          end
        end
      end

      # sort image collections by extension and location
      coll_by_ext = {}
      img_locs.each do |k, v|
        max = v.max_by { |sub_k, sub_v| sub_v.length }
        coll_by_ext[k] = max[1] if max[1].length > 9
      end

      # return largest group of most preferred file type
      acceptable_image_formats.each do |ext|
        if coll_by_ext.key?(ext)
          @img_coll = coll_by_ext[ext]
          @ext = ext
          return
        end
      end
    end

    def import_image_archive
      x, y, z = extract_file_and_metadata
      if x.uniq.length != 1 || y.uniq.length != 1 || z == 0
        cleanup_tmp_files
        # error out, no images or different kinds of images
      else
        @x = x.first
        @y = y.first
        @z = z
        @linear_scale_factor = linear_scale_factor
      end
    end

    # extracts zipped images and grabs x, y, z dimensions
    def extract_file_and_metadata(format='.dcm')
      x = []
      y = []
      z = 0
      Zip::File.open(source_path) do |zip_file|
        img_coll.each do |f|
          f_path = File.join(input_path, File.basename(f))
          zip_file.extract(f, f_path)
          x_dim, y_dim = image_dims(f_path)
          x << x_dim if x_dim
          y << y_dim if y_dim
          z += 1 if x_dim && y_dim
        end
      end
      return x, y, z
    end

    def image_dims(f)
      img = MiniMagick::Image.open(f)
      if img.valid?
        return img.width, img.height
      end
    end

    def linear_scale_factor
      ( (300.0**3) / (x.to_f * y.to_f * z.to_f) )**( 1.0/3.0 )
    end

    def uncompress_dcm
      dcmdjpeg = Morphosource::Derivatives::Dcmdjpeg.new(input_path, input_path)
      dcmdjpeg.call
    end

		def img_to_jpeg
      fiji = Morphosource::Derivatives::Fiji.new(input_path, jpeg_path, linear_scale_factor)
      fiji.call
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
      erb_src = File.join(__dir__, 'manifest.json.erb')
      txt_dst = File.join(tmp_dir_path, File.basename(erb_src, '.erb'))
      File.open(txt_dst, 'w') do |f|
        f.write(ERB.new(File.read(erb_src)).result(binding))
      end
      txt_dst
		end

    def gen_dcm_path(id)
      id.to_s.chars.each_slice(2).map(&:join).join('/')
    end

    def dicom_series
      id = directives[:file_set_id]
      file_n = Dir[File.join(output_path, '**', '*')].count { |file| File.file?(file) }
      ((1..file_n).to_a.map { |i| "\"derivatives/#{gen_dcm_path(id)}/#{i}.dcm\""}).join(',')
      #((1..file_n).to_a.map { |i| "\"downloads/#{id}?file=dcm#{i}\""}).join(',')
    end

    def base_derivative_path
      # todo: add derived path here if necessary
      ''
    end

    def write_files
      # write manifest file
      output_file_service.call(manifest_path, directives)

      # write dcm images
      files = (Dir.entries(output_path).select {|f| File.file? File.join(output_path, f) }).sort
      files.each_with_index { |f, i| write_dcm_file(File.join(output_path, f), (i+1).to_s+'.dcm') }
    end

    def write_dcm_file(f_path, new_f_name)
      f_directives = directives.merge( { url: File.join(dcm_derivative_path, new_f_name) } )
      output_file_service.call(f_path, f_directives)
    end

    def dcm_derivative_path
      File.join(File.dirname(directives[:url]), File.basename(directives[:url])[0])
    end

		def cleanup_tmp_files
			FileUtils.remove_dir tmp_dir_path
		end
	end
end
