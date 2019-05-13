require 'open3'
require 'logger'

module Morphosource::Derivatives
  class DcmdjpegError < RuntimeError
  end

  class Dcmdjpeg
    include Open3

    attr_reader :source_path, :out_path, :file_path, :file_out_path
    def initialize(source_path, out_path)
      @source_path = source_path
      @out_path = out_path
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
          next if File.extname(f).downcase != '.dcm' && File.extname(f).downcase != '.dicom'
            @file_path = File.join(source_path, f)
            @file_out_path = File.join(out_path, f)
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
        "dcmdjpeg #{file_path} #{file_out_path}"
      end
  end
end
