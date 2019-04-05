module Ms1to2
	class Ms1InputData
		def self.standard_tables
			['ca_users', 'ms_facilities', 'ms_institutions', 'ms_media_files', 
			 'ms_media', 'ms_projects', 'ms_scanners', 'ms_specimens']
		end

		attr_reader *standard_tables, :ms_media_combined, :input_path

		# Import multiple CSVs making up coherent Ms1 data hierarchy.
		# @param [String] input_path Directory path to CSVs and Files
		def initialize(input_path)
			@input_path = input_path
			import_standard_tables
			import_special_tables
		end	

		def import_standard_tables
			standard_tables.each do |tname|
				f = File.join(input_path, tname+'.csv')
				if File.exists?(f)
					table = {}
					CSVParser.new(f).each do |attrs|
						table[attrs[transform_tname_to_key(tname)].first] = attrs
					end
					instance_variable_set("@#{tname}", table)
				end
			end
		end

		# Combines ms_media_files and ms_media tables and includes file path information
		def import_special_tables
			@ms_media_combined = {}
			ms_media_files.each do |mf_id, mf_hash|
				m = ms_media[mf_hash[:media_id].first]
				ms_media_combined[mf_id] = mf_hash.merge(
					m.map {|k, v| [('m_'+k.to_s).to_sym, v] }.to_h)
			end
		end

		def standard_tables
			Ms1InputData.standard_tables
		end

		def transform_tname_to_key(tname)
			case tname
			when 'ms_facilities'
				'facility_id'.to_sym
			when 'ms_media'
				'media_id'.to_sym
			else
				(tname.split('_',2)[1].chomp('s')+'_id').to_sym
			end
		end

		def find(tname, id, key)
			if standard_tables.include?(tname.to_s) && send(tname).key?(id)
				send(tname)[id][key]
			else
				[]
			end
		end
	end
end