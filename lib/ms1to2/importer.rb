module Ms1to2
	class Importer
		attr_accessor :input_path, :media, :ie, :pe

		def initialize(input_path)
			@input_path = input_path
		end

		def call
			# Iterate through models and import table
			models.each do |m|
				puts(m)
				import_table(m)
			end
		end

		def import_table(m)
			m == :Media ? import_media(m) : import_standard(m)
		end

		def import_standard(m)
			csv_importer = ::Importer::CSVImporter.new(
				File.join(input_path, csvfile(m)),
				'', 
				{ :depositor => 'julia.m.winchester@gmail.com', :model => m.to_s } )
			csv_importer.import_all
		end

		# Special case media methods

		def import_media(csvfile, m)
			@media = get_table(m)
			@ie = get_table(csvfile(:ImagingEvent))
			@pe = get_table(csvfile(:ProcessingEvent))
			combined_table = {}.merge(media).merge(ie).merge(pe)
			
			ids_in_order.each do |id|
				attrs = combined_table[id]
				attrs.merge({ :depositor => 'julia.m.winchester@gmail.com' })
				csv_importer = Importer::CSVImporter.new('', '', { :model => to_model(id) })
				csv_importer.import_batch_object(attrs)
			end
		end

		def to_model(id)
			case id[0]
			when 'M'
				:Media
			when 'I'
				:ImagingEvent
			when 'P'
				:ProcessingEvent
			end
		end

		def ids_in_order
			relations = {}
			[media, ie, pe].each do |t|
				t.each { |k, v| relations[k] = v[:parent_id] }
			end
			sort_order(relations)
		end

		def sort_order(relations)
			relations = relations.clone
			ordered = []
			relations.each do |id, parent_id|
				if ordered.include?(id)
					relations.delete(id)
				elsif parent_id.presence
					if ordered.include?(parent_id)
						# add id after parent_id
						ordered.insert(ordered.index(parent_id)+1, id)
						relations.delete(id)
					elsif relations.include?(parent_id)
						nested_ids = get_nested_ids(id, relations).reverse
						ordered = ordered + nested_ids
						relations.delete_if { |v| nested_ids.include?(v) }
					end
				else
					ordered << relations.delete(id)
				end
			end
			ordered
		end

		def get_nested_ids(id, id_array, nested_ids=[])
			nested_ids << id
			if id_array[id].presence
				nested_ids = get_nested_ids(id_array[id], id_array, nested_ids)
			end
			nested_ids
		end

		def get_table(csvfile)
			{}.tap do |t|
				CSVParser.new(File.join(input_path, csvfile)).each do |attrs|
					t[attrs[:id]] = attrs
				end
			end
		end

		# Utility methods

		def csvfile(m)
			m.to_s.underscore+'.csv'
		end

		def models
			[:Institution]
		end
	end
end