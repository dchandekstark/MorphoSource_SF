module Ms1to2
  module Models
    class Media < BaseObject
      def mappings
        {
          :legacy_media_file_id => :media_file_id,
          :legacy_media_group_id => :media_id,
          :ark => :ark,
          :doi => :doi,
          :media_type => :media_type,
          :file_path => :file,
          :created_on => :date_uploaded,
          :title => :short_description,
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
        [:depositor, :parent_id, :collection_id, :part, :side, :description, :cite_as, 
         :available, :unit, :funding_attribution,
         :license, :rights_holder, :x_spacing, 
         :y_spacing, :z_spacing, :modality, :visibility]
      end
    end
  end
end