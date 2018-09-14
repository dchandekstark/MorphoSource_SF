# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension( Hydra::ContentNegotiation )

  # Add custom metadata fields to show view

  def agreement_uri
    self[Solrizer.solr_name('agreement_uri')]
  end

  def cite_as
    self[Solrizer.solr_name('cite_as')]
  end

  def funding
    self[Solrizer.solr_name('funding')]
  end

  def map_type
    self[Solrizer.solr_name('map_type')]
  end

  def media_type
    self[Solrizer.solr_name('media_type')]
  end

  def modality
    self[Solrizer.solr_name('modality')]
  end

  def orientation
    self[Solrizer.solr_name('orientation')]
  end

  def part
    self[Solrizer.solr_name('part')]
  end

  def rights_holder
    self[Solrizer.solr_name('rights_holder')]
  end

  def scale_bar
    self[Solrizer.solr_name('scale_bar')]
  end

  def side
    self[Solrizer.solr_name('side')]
  end

  def unit
    self[Solrizer.solr_name('unit')]
  end

  def x_spacing
    self[Solrizer.solr_name('x_spacing')]
  end

  def y_spacing
    self[Solrizer.solr_name('y_spacing')]
  end

  def z_spacing
    self[Solrizer.solr_name('z_spacing')]
  end
  
end
