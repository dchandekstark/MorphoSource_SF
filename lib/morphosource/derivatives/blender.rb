require 'open3'
require 'logger'

module Morphosource::Derivatives
  class BlenderError < RuntimeError
  end

  class Blender
    include Open3

    class_attribute :tool_path

    attr_reader :source_path, :out_path, :units
    def initialize(source_path, out_path, units = nil, tool_path = nil)
      @source_path = source_path
      @out_path = out_path
      @units = units.presence || 'm'
      @tool_path = tool_path
    end

    def call
      unless File.exists?(source_path)
        raise Morphosource::Derivatives::BlenderError.new("Source file: #{source_path} does not exist.")
      end

      internal_call # to do add some output/post-process controls
    end

    def tool_path
      @tool_path || Morphosource::Derivatives.blender_path
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
        "#{tool_path}/blender --background --factory-startup --addons io_scene_gltf2 --python #{tool_path}/scripts/blender_derive_mesh.py -- -i #{source_path} -o #{out_path} -u #{units}"
      end
  end
end
