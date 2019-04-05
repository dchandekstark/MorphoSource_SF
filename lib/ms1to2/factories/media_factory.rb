module Ms1to2
	module Factories
		class MediaFactory < Factory
			self.ms1_table_name = :ms_media_files
			self.ms2_model = :Media

			attr_accessor :ms1_mg_table, :ms2_ie_model, :ms2_pe_model, :ms2_ie_table, :ms2_pe_table

			def initialize(ms1_input_data, ms2_output_data)
				super
				@ms1_mg_table = :ms_media
				@ms2_ie_model = :ImagingEvent
				@ms2_pe_model = :ProcessingEvent
				@ms2_ie_table = {}
				@ms2_pe_table = {}
			end

			def run
				process_table
				#add_ingest_order
				output_tables
			end

			def output_tables
				# media table
				m_table = ms2_output_data.public_send(ms2_model_var(ms2_model)).merge(ms2_table)
				ms2_output_data.instance_variable_set("@#{ms2_model_var(ms2_model)}", m_table)

				# imaging event table
				ie_table = ms2_output_data.public_send(ms2_model_var(ms2_ie_model)).merge(ms2_ie_table)
				ms2_output_data.instance_variable_set("@#{ms2_model_var(ms2_ie_model)}", ie_table)

				# processing event table
				pe_table = ms2_output_data.public_send(ms2_model_var(ms2_pe_model)).merge(ms2_pe_table)
				ms2_output_data.instance_variable_set("@#{ms2_model_var(ms2_pe_model)}", pe_table)
			end

			### PROCESSING METHODS ###

			def process_table
				ms1_table.each do |k, v|
					id = derive_mf_id(k)
					mg = ms1_input_data.send(ms1_mg_table)[v[:media_id].first]
					#process_row(id, v, mg) unless (model.exists?(id) || ms2_table.key?(id) || ms2_output_data.exists?(ms2_model_var(ms2_model), id))
					process_row(k, v, mg) unless (ms2_table.key?(id) || ms2_output_data.exists?(ms2_model_var(ms2_model), id))		
				end
			end

			def process_row(ms1_id, mf, mg)
				if mf[:file_type].first == "1"
					# raw files, no parent, media and imaging event
					process_media_ie(ms1_id, mf, mg)
				elsif mf[:file_type].first == "2"
					if mf[:derived_from_media_file_id].presence
						# standard child media, media and processing event
						process_media_pe(ms1_id, mf, mg)
					else
						# media with absentee parent, media, imaging, and processing event
						process_media_ie_pe(ms1_id, mf, mg)
					end
				end
			end

			def process_media_ie(ms1_id, mf, mg)
				ie_id = derive_ie_id(ms1_id)
				mf_id = derive_mf_id(ms1_id)

				process_ie(ie_id, mg)
				process_mf(mf_id, mf, mg, ie_id)
			end

			def process_media_pe(ms1_id, mf, mg)
				pe_id        = derive_pe_id(ms1_id)
				pe_parent_id = derive_mf_id(mf[:derived_from_media_file_id].first.to_i.to_s)
				mf_id        = derive_mf_id(ms1_id)

				process_pe(pe_id, mg, pe_parent_id)
				process_mf(mf_id, mf, mg, pe_id)
			end

			def process_media_ie_pe(id, mf, mg)
				ie_id = derive_ie_id(ms1_id)
				pe_id = derive_pe_id(ms1_id)
				mf_id        = derive_mf_id(ms1_id)

				process_ie(ie_id, mg)
				process_pe(pe_id, mg, ie_id)
				process_mf(mf_id, mf, mg, pe_id)
			end

			### IE-SPECIFIC METHODS

			def process_ie(id, mg)
				ms2_ie_table[id] = ms1to2_model(ms2_ie_model).
					new(id, mg, derive_special_fields_ie(mg)).
					ms2_attributes
			end

			def derive_ie_id(id)
				"IE"+id.to_s
			end

			def derive_special_fields_ie(v)
				{
					:depositor => derive_depositor(v[:user_id]),
					:parent_id => derive_ie_parents(v),
					:ie_modality => derive_ie_modality(v),
					:power => derive_ie_power(v)
				}
			end

			def derive_ie_parents(v)
				["B"+v[:specimen_id].first, "D"+v[:scanner_id].first]
			end

			def derive_ie_modality(v)
				device_id = "D"+v[:scanner_id].first
				ms2_output_data.find(ms2_model_var(:Device), device_id, :modality)
			end

			def derive_ie_power(v)
				v[:scanner_watts].presence ? [(v[:scanner_watts].first.to_f/1000.0).to_s] : nil
			end

			### PE-SPECIFIC METHODS ###

			def process_pe(id, mg, parent_id)
				ms2_pe_table[id] = ms1to2_model(ms2_pe_model).
					new(id, mg, derive_special_fields_pe(mg, parent_id)).
					ms2_attributes
			end

			def derive_pe_id(id)
				"PE"+id.to_s
			end

			def derive_special_fields_pe(v, parent_id)
				{
					:depositor => derive_depositor(v[:user_id]),
					:parent_id => parent_id
				}
			end

			### MF-SPECIFIC METHODS ###

			def process_mf(id, mf, mg, parent_id)
				ms2_table[id] = ms1to2_model(ms2_model).
					new(id, mf, derive_special_fields_mf(mf, mg, parent_id)).
					ms2_attributes
			end

			def derive_mf_id(id)
				"M"+id.to_s
			end

			def derive_special_fields_mf(mf, mg, parent_id)
				{
					:depositor => derive_depositor(mf[:user_id]),
					:parent_id => parent_id,
					:part => derive_part(mf, mg),
					:side => derive_side(mf, mg),
					:description => derive_description(mf, mg),
					:cite_as => derive_cite_as(mg),
					:available => derive_available(mf, mg),
					:unit => derive_unit(mg),
					:funding_attribution => derive_funding_attribution(mg),
					:license => derive_license(mg),
					:rights_holder => derive_rights_holder(mg),
					:x_spacing => derive_x_spacing(mg),
					:y_spacing => derive_y_spacing(mg),
					:z_spacing => derive_z_spacing(mg)
				}
			end

			def derive_part(mf, mg)
				mf[:element].presence || mg[:element].presence || []
			end

			def derive_side(mf, mg)
				val = mf[:side].presence || mg[:side].presence || []
				[mf_control_vocab_mappings[:side][val.first]] if val.presence
			end

			def derive_description(mf, mg)
				val = ''
				val += ('Migrated MorphoSource 1 Media File Title: ' + mf[:title].first + '\n') if mf[:title].presence
				val += ('Migrated MorphoSource 1 Media Group Title: ' + mg[:title].first + '\n') if mg[:title].presence
				val += ('Migrated MorphoSource 1 Media File Description: ' + mf[:notes].first + '\n') if mf[:notes].presence
				val += ('Migrated MorphoSource 1 Media Group Description: ' + mg[:notes].first + '\n') if mg[:notes].presence
				[val]
			end

			def derive_cite_as(mg)
				val = ''
				val += ('Migrated MorphoSource 1 Media Citation Instructions: ' + mg[:media_citation_instruction1].first + ' provided access to these data') if mg[:media_citation_instruction1].presence
				val += (' ' + mg[:media_citation_instruction2].first) if mg[:media_citation_instruction2].presence
				val += (' ' + mg[:media_citation_instruction3].first) if mg[:media_citation_instruction3].presence
				val += ('. The files were downloaded from www.MorphoSource.org, Duke University.') if mg[:media_citation_instruction1].presence
				[val]
			end

			def derive_available(mf, mg)
				mf[:published_on].presence || mg[:published_on].presence || []
			end

			def derive_unit(mg)
				(derive_x_spacing(mg) || derive_y_spacing(mg) || derive_z_spacing(mg)) ? ["Mm"] : []
			end

			def derive_funding_attribution(mg)
				mg[:grant_support]
			end

			def derive_license(mg)
				val = mg[:copyright_license]
				[mf_control_vocab_mappings[:copyright_license][val.first]] if val.presence
			end

			def derive_rights_holder(mg)
				mg[:copyright_info]
			end

			def derive_x_spacing(mg)
				mg[:scanner_x_resolution]
			end

			def derive_y_spacing(mg)
				mg[:scanner_x_resolution]
			end

			def derive_z_spacing(mg)
				mg[:scanner_x_resolution]
			end

			def mf_control_vocab_mappings
				{
					:side => {
						'LEFT' => 'Left',
						'RIGHT' => 'Right',
						'MIDLINE' => 'Midline',
						'NA' => 'NotApplicable',
						'UNKNOWN' => 'Unknown'
					},
					:copyright_license => {
						1 => 'http://creativecommons.org/publicdomain/zero/1.0/',
						2 => 'https://creativecommons.org/licenses/by/4.0/',
						3 => 'https://creativecommons.org/licenses/by-nc/4.0/',
						4 => 'https://creativecommons.org/licenses/by-sa/4.0/',
						5 => 'https://creativecommons.org/licenses/by-nc-sa/4.0/',
						6 => 'https://creativecommons.org/licenses/by-nd/4.0/',
						7 => 'https://creativecommons.org/licenses/by-nc-nd/4.0/'
					}
				}
			end

			### UTILITY METHODS ###

			def media_exists?(ms1_id)
				ms2_id = derive_id(ms1_id)
				model.exists?(ms2_id) || ms2_output_data.exists?(ms2_model_var(m2_model), ms2_id) || ms2_table.key?(ms2_id)
			end
		end
	end
end