module Morphosource
  # Module to define core (non-modality specific) metadata properties for 
  # media works
  module MediaMetadata
	extend ActiveSupport::Concern

	included do 
	  # -- Fields present on edit/show form --

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

	  # -- Fields not present on edit/show form --
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
	end
  end
end