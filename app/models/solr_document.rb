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

  # MorphoSource customizations
  def file_ext
    File.extname(title.kind_of?(Array) ? title.first : title)
  end

  def mesh? # TODO: Needs to be adjusted to use mime types when FITS issue is dealt with
    accepted_formats = [".ply", ".stl", ".obj", ".gltf"]
    accepted_formats.include? file_ext
  end

  def mesh_mime_type # TODO: Temporary, should not exist forever
    mesh_mime_types = { ".ply" => "application/ply", 
                        ".stl" => "application/sla", 
                        ".obj" => "text/plain", 
                        ".gltf" => "model/gltf+json" }
    mesh_mime_types[file_ext]
  end
end
