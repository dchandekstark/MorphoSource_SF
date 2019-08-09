module Ms1to2
  module Factories
    class InstitutionFactory < ObjectFactory
      self.ms1_table_name = :ms_institutions
      self.ms2_model = :Institution

      def process_table
        super
        process_facility_table
        output_table
      end

      def process_facility_table
        ms1_input_data.public_send(:ms_facilities).each do |k, v|
          id = derive_facility_id(k)
          if ms2_table.key?(id) || ms2_output_data.exists?(ms2_model_var, id)
            next
          elsif matching_institution(v[:institution].first)
            add_institution_match(k, matching_institution(v[:institution].first))
          else
            process_facility_row(id, v)
            add_institution_match(k, id)
          end
        end
      end

      def process_facility_row(id, v)
        ms2_table[id] = ms1to2_model(:InstitutionFromFacility).new(
          id, v, derive_special_fields(v)).ms2_attributes
      end

      def matching_institution(institution_name)
        if ms2_output_data.find_ids(ms2_model_var, :title, institution_name).first
          ms2_output_data.find_ids(ms2_model_var, :title, institution_name).first
        else
          ms2_table.each do |k, v|
            return k if v.key?(:title) && v[:title] == institution_name
          end
          nil
        end
      end

      def add_institution_match(facility_id, institution_id)
        t = ms2_output_data.public_send('f_to_i').merge(
          { facility_id => { 'facility_id' => facility_id, 'institution_id' => institution_id } }
        )
        ms2_output_data.instance_variable_set("@f_to_i", t)
      end

      def derive_id(id)
        hyraxify('I'+id.to_s)
      end

      def derive_facility_id(id)
        hyraxify('IF'+id.to_s)
      end

      def derive_special_fields(v)
        {
          :depositor => derive_depositor(v[:user_id])
        }
      end
    end
  end
end