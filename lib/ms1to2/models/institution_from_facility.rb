module Ms1to2
	module Models
		class InstitutionFromFacility < BaseObject
			def mappings
				{
					:institution => :title,
					:city => :city,
					:state_province => :stateprov,
					:country => :country
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