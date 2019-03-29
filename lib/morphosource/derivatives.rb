module Morphosource
	module Derivatives
		extend ActiveSupport::Concern
    	extend ActiveSupport::Autoload
    	extend Hydra::Derivatives

    	autoload :MeshDerivatives

    	def self.gltf_pipeline_path
    		Hyrax.config.gltf_pipeline_path
    	end

    	def self.blender_path
    		Hyrax.config.blender_path
    	end
	end
end