module Ms1to2
	module Models
		class Institution < BaseObject
			def mappings
				{
					:name => :title,
					:description => :description,
					:city => :location_city,
					:state_province => :location_state,
					:country => :location_country
				}
			end

			def control_vocab_mappings
				{}
			end

			def expected_special_fields
				[:depositor]
			end
		end
	end
end