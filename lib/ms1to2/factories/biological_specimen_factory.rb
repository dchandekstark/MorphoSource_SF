module Ms1to2
  module Factories
    class BiologicalSpecimenFactory < ObjectFactory
      self.ms1_table_name = :ms_specimens
      self.ms2_model = :BiologicalSpecimen

      def derive_id(id)
        hyraxify("S"+id.to_s)
      end

      def derive_special_fields(v)
        {
          :depositor => derive_depositor(v[:user_id]),
          :parent_id => hyraxify('I' + v[:institution_id].first),
          :collection_id => derive_collection_id(v[:project_id])
        }
      end
    end
  end
end