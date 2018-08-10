module Morphosource
  # Module to define core (non-modality specific) metadata properties for 
  # media works
  module MediaMetadata
	extend ActiveSupport::Concern

	included do 
	  # -- Core metadata --

	  # Required select values 
	  property :modality, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/captureDevice") do |index|
	  	index.as :stored_searchable, :facetable
	  end

	  property :media_type, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/subtypeLiteral"), multiple: false do |index|
		index.as :stored_searchable, :facetable
	  end

	  # Optional select values
	  property :side, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/comments") do |index|
		index.as :stored_searchable, :facetable
	  end

	  # Optional free text values
	  property :part, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/subjectPart") do |index|
		index.as :stored_searchable
	  end

	  property :orientation, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/subjectOrientation") do |index|
		index.as :stored_searchable
	  end

	  property :funding, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/fundingAttribution") do |index|
		index.as :stored_searchable
	  end

	  property :cite_as, predicate: ::RDF::URI.new("http://ns.adobe.com/photoshop/1.0/Credit"), multiple: false do |index|
		index.as :stored_searchable
	  end

	  property :rights_holder, predicate: ::RDF::URI.new("http://ns.adobe.com/xap/1.0/rights/Owner") do |index|
		index.as :stored_searchable
	  end

	  property :agreement_uri, predicate: ::RDF::URI.new("http://ns.adobe.com/xap/1.0/rights/UsageTerms") do |index|
		index.as :stored_searchable
	  end

	  # Fields not present on edit/show form
	  property :legacy_media_file_id, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/providerManagedID"), multiple: false do |index|
		index.as :stored_searchable
	  end

	  property :legacy_media_group_id, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/IDofContainingCollection"), multiple: false do |index|
		index.as :stored_searchable
	  end

	  property :uuid, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/mediaUUID"), multiple: false do |index|
		index.as :stored_searchable
	  end

	  property :ark, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/mediaARK"), multiple: false do |index|
		index.as :stored_searchable
	  end

	  property :doi, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/mediaDOI"), multiple: false do |index|
		index.as :stored_searchable
	  end

	  property :available, predicate: ::RDF::Vocab::DC.available, multiple: false do |index|
		index.as :stored_searchable
	  end

	  # -- Media type-specific metadata --

	  # ImageStack fields
	  property :number_of_images_in_set, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/dicomNumberOfSeriesRelatedInstances"), multiple: false do |index|
		index.as :stored_searchable
	  end

	  # CTImageStack fields
	  property :x_spacing, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/dicomPixelSpacingWidth"), multiple: false do |index|
		index.as :stored_searchable
	  end

	  property :y_spacing, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/dicomPixelSpacingHeight"), multiple: false do |index|
		index.as :stored_searchable
	  end

	  property :z_spacing, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/dicomSpacingBetweenSlices"), multiple: false do |index|
		index.as :stored_searchable
	  end

	  # PhotogrammetryImageStack fields
	  property :scale_bar_target_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/scaleBarTargetType"), multiple: false do |index|
		index.as :stored_searchable
	  end

	  property :scale_bar_distance, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/scaleBarDistance"), multiple: false do |index|
		index.as :stored_searchable
	  end

	  # Mesh and CTImageStack field
	  property :unit, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/ACExt/units"), multiple: false do |index|
		index.as :stored_searchable, :facetable
	  end

	  # Mesh field
	   property :map_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/mapType") do |index|
		index.as :stored_searchable, :facetable
	  end


	end
  end
end