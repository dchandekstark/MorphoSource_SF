# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  class MediaPresenter < Hyrax::WorkShowPresenter
    delegate :agreement_uri, :cite_as, :funding, :map_type, :media_type, :modality, :orientation, :part, :rights_holder, :scale_bar, :side, :unit, :x_spacing, :y_spacing, :z_spacing, to: :solr_document
  end
end
