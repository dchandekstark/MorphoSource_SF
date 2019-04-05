module Ms1to2
	module Factories
		class BiologicalSpecimenFactory < Factory
			self.ms1_table_name = :ms_specimens
			self.ms2_model = :BiologicalSpecimen

			def derive_id(id)
				"S"+id.to_s
			end

			def derive_special_fields(v)
				{
					:depositor => derive_depositor(v[:user_id]),
					:parent_id => 'I' + v[:institution_id].first
				}
			end
		end
	end
end