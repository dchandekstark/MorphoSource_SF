# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  class BiologicalSpecimenPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :bibliographic_citation, :catalog_number, :collection_code, :numeric_time, :original_location,
             :periodic_time, :vouchered, :idigbio_recordset_id, :idigbio_uuid, :is_type_specimen, :occurrence_id, :sex,
             :geographic_coordinates,  to: :solr_document
  



   	# todo: this method should not be needed any more. Remove later 
   	def parent_title(type)
    	title = ''
    	grouped_presenters(filtered_by: type).each_pair do |_, items| 
        items.each do |item|
        	title = item.title.first 
          # link_to item.title.first, url_for_document(item) 
        end
			end
			title 
    end

   	def parent_institution_title
    	title = Institution.where('member_ids_ssim' => solr_document.id).first.title.first
    	if title.nil?
    		title = ''
    	end
			title
    end

   	def parent_institution_code
    	code = Institution.where('member_ids_ssim' => solr_document.id).first.institution_code.first
    	if code.nil?
    		code = ''
    	end
			code
    end

    def general_details_partial
    	'general_details_biological_specimens'
#    	'general_details_' + @presenter.model_name.plural 
    end


    def identifiers_partial
    	'identifiers_biological_specimens'
    end

  end
end
