module Ms1to2
	module Models
		class Media < BaseObject
			def mappings
				{
					#:grant_support => :funding_attribution,
					#:copyright_license => :license,
					#:copyright_info => :rights_holder,
					:legacy_media_file_id => :media_file_id,
					:legacy_media_group_id => :media_id,
					:ark => :ark,
					:doi => :doi,
					#:x_spacing => :scanner_x_resolution,
					#:y_spacing => :scanner_y_resolution,
					#:z_spacing => :scanner_z_resolution,
					:media_type => :media_type
				}
			end

			def control_vocab_mappings
				{
					:side => {
						'LEFT' => 'Left',
						'RIGHT' => 'Right',
						'MIDLINE' => 'Midline',
						'NA' => 'NotApplicable',
						'UNKNOWN' => 'Unknown'
					},
					:copyright_license => {
						'1' => 'http://creativecommons.org/publicdomain/zero/1.0/',
						'2' => 'https://creativecommons.org/licenses/by/4.0/',
						'3' => 'https://creativecommons.org/licenses/by-nc/4.0/',
						'4' => 'https://creativecommons.org/licenses/by-sa/4.0/',
						'5' => 'https://creativecommons.org/licenses/by-nc-sa/4.0/',
						'6' => 'https://creativecommons.org/licenses/by-nd/4.0/',
						'7' => 'https://creativecommons.org/licenses/by-nc-nd/4.0/'
					}
				}
			end

			def expected_special_fields
				[:depositor, :parent_id, :part, :side, :description, :cite_as, 
				 :available, :unit, :funding_attribution,
				 :license, :rights_holder, :x_spacing, 
				 :y_spacing, :z_spacing]
			end
		end
	end
end