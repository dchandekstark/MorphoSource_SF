require 'open3'
require 'logger'

module Morphosource::Derivatives
  class Img2dcmError < RuntimeError
  end

  class Img2dcm
    include Open3

    attr_reader :source_path, :out_path, :x, :y, :z, :thickness, :file_path, :file_out_path
    def initialize(source_path, out_path, x=nil, y=nil, z=nil, thickness=nil)
      @source_path = source_path
      @out_path = out_path
      @x = x
      @y = y
      @z = z
      @thickness = thickness
    end

    def call
      unless Dir.exists?(source_path)
        raise Morphosource::Derivatives::Img2dcmError.new("Source directory: #{source_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    def logger
      @logger ||= activefedora_logger || Logger.new(STDERR)
    end

    protected

      # Remove any non-XML output that precedes the <?xml> tag
      # todo: possibly remove blender errors and non-xml output
    # def post_process(raw_output)
    #   md = /\A(.*)(<\?xml.*)\Z/m.match(raw_output)
    #   logger.warn "----- WARNING ----- Blender produced non-xml output: \"#{md[1].chomp}\"" unless md[1].empty?
    #   md[2]
    # end

      def internal_call
        Dir.foreach(source_path) do |f|
          next if File.extname(f).downcase != '.jpg'
            @file_path = File.join(source_path, f)
            @file_out_path = File.join(out_path, File.basename(f, '.jpg')+'.dcm')
            process_file
        end
      end

      def process_file
        stdin, stdout, stderr, wait_thr = popen3(command)
        begin
          out = stdout.read
          err = stderr.read
          exit_status = wait_thr.value
          raise "Unable to execute command \"#{command}\"\n#{err}" unless exit_status.success?
          out
        ensure
          stdin.close
          stdout.close
          stderr.close
        end
      end

      def command
        "img2dcm " +
          ( x && y ? "-k 'PixelSpacing=" + x.to_s + "\\" + y.to_s + "' " : "" ) +
          ( z ? "-k 'SpacingBetweenSlices=" + z.to_s + "' " : "") + 
          ( thickness ? "-k 'SliceThickness=" + thickness.to_s + "' " : "") + 
          "#{file_path} #{file_out_path}"
      end
  end
end
