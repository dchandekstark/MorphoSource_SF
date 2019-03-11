# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
module Hyrax
  class CulturalHeritageObjectPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :bibliographic_citation, :catalog_number, :collection_code, :numeric_time, :original_location,
             :periodic_time, :vouchered, :cho_type, :material, :short_title, :geographic_coordinates, to: :solr_document

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

  end
end
