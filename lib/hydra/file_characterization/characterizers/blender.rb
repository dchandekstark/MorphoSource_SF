require 'hydra/file_characterization/exceptions'
require 'hydra/file_characterization/characterizer'
require 'logger'
module Hydra::FileCharacterization::Characterizers
  class Blender < Hydra::FileCharacterization::Characterizer

    protected

      def command
        ######    "#{tool_path} -i \"#{filename}\""
        #####     "/vagrant/blender/blender --background --python /vagrant/blender/test/testply.py -- /vagrant/blender/test/turkey_femur_sbu_77.ply"
byebug
        "/vagrant/blender/blender --background --python /vagrant/blender/test/blender_characterize_mesh.py -- #{filename}"
      end

      # Remove any non-XML output that precedes the <?xml> tag
      # todo: remove 'blender output' at the end
      def post_process(raw_output)
byebug        
        md = /\A(.*)(<\?xml.*)\Z/m.match(raw_output)
        logger.warn "----- WARNING ----- Blender produced non-xml output: \"#{md[1].chomp}\"" unless md[1].empty?
        md[2]
      end
  end
end
