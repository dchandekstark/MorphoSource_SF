# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  # Generated form for Media
  class MediaForm < Hyrax::Forms::WorkForm
    self.model_class = ::Media

    # Customizing field terms

    self.terms = [:title, :modality, :media_type, :x_spacing, :y_spacing, :z_spacing, 
                    :scale_bar_target_type, :scale_bar_distance, :unit, :map_type, 
                    :part, :side, :orientation, 
                    :description, :keyword, :identifier, :related_url, :creator, :date_created, 
                    :funding, :license, :rights_statement, :agreement_uri, 
                    :rights_holder, :cite_as, :publisher,     
                    :representative_id, :thumbnail_id, :rendering_ids, :files,
                    :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
                    :visibility_during_lease, :lease_expiration_date, :visibility_after_lease,
                    :visibility, :ordered_member_ids, :in_works_ids,
                    :member_of_collection_ids, :admin_set_id]

    self.required_fields = [:title, :modality, :media_type]

  end
end
