module Ms1to2
	module Models
		class Device < BaseObject
			def mappings
				{
					:description => :description
				}
			end

			def control_vocab_mappings
				{
					:modality => {
						'MicroNanoXRayComputedTomography' => 'MicroNanoXRayComputedTomography',
						'MedicalXRayComputedTomography' => 'MedicalXRayComputedTomography',
						'MagneticResonanceImaging' => 'MagneticResonanceImaging',
						'PositronEmissionTomography' => 'PositronEmissionTomography',
						'SynchrotronImaging' => 'SynchrotronImaging',
						'NeutrinoImaging' => 'NeutrinoImaging',
						'Photogrammetry' => 'Photogrammetry',
						'StructuredLight' => 'StructuredLight',
						'LaserScan' => 'LaserScan',
						'ConfocalImageStacking' => 'ConfocalImageStacking',
						'Infrared' => 'Infrared',
						'ReflectanceTransformationImaging' => 'ReflectanceTransformationImaging',
						'Photography' => 'Photography',
						'ScanningElectronMicroscopy' => 'ScanningElectronMicroscopy'
					}
				}
			end

			def expected_special_fields
				[:depositor, :parent_id, :title, :creator, :modality, :facility]
			end
		end
	end
end