# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'

RSpec.describe Hyrax::MediaPresenter do
  subject(:presenter) { described_class.new(SolrDocument.new(work.to_solr), nil) }

  let(:title)             {['Media Work Title']}
  let(:publisher)         {['Random House']}
  let(:identifier)        {['123ABC']}
  let(:keyword)           {['purple']}
  let(:date_created)      {['January 1, 1977']}
  let(:related_url)       {['www.aaa.com']}
  let(:rights_statement)  {['In Copyright - EU Orphan Work']}
  let(:agreement_uri)     {['www.zzz.com']}
  let(:cite_as)           {['Media Work Citation']}
  let(:funding)           {['NSF']}
  let(:map_type)          {['Color Map']}
  let(:media_type)        {['PhotogrammetryImageStack']}
  let(:modality)          {['MagneticResonanceImaging']}
  let(:orientation)       {['Media Orientation']}
  let(:part)              {['Part 7']}
  let(:rights_holder)     {['Martha Stewart']}
  let(:scale_bar)         {['Type: Scale_bar_target_type, Distance: Scale_bar_distance, Units: Scale_bar_units']}
  let(:side)              {['left']}
  let(:unit)              {['inch']}
  let(:x_spacing)         {['5']}
  let(:y_spacing)         {['7']}
  let(:z_spacing)         {['9']}
  let(:visibility)        { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:user)              { 'test@example.com' }

  let :work do
    Media.create(title:            title,
                 publisher:        publisher,
                 identifier:       identifier,
                 keyword:          keyword,
                 date_created:     date_created,
                 related_url:      related_url,
                 rights_statement: rights_statement,
                 agreement_uri:    agreement_uri,
                 cite_as:          cite_as,
                 funding:          funding,
                 map_type:         map_type,
                 media_type:       media_type,
                 modality:         modality,
                 orientation:      orientation,
                 part:             part,
                 rights_holder:    rights_holder,
                 scale_bar:        scale_bar,
                 side:             side,
                 unit:             unit,
                 x_spacing:        x_spacing,
                 y_spacing:        y_spacing,
                 z_spacing:        z_spacing,
                 visibility:       visibility,
                 depositor:        user)
  end

  it { is_expected.to have_attributes(title: title, publisher: publisher, identifier: identifier, keyword: keyword, date_created: date_created, related_url: related_url, rights_statement: rights_statement, agreement_uri: agreement_uri, cite_as: cite_as, funding: funding, map_type: map_type, media_type:  media_type, modality: modality, orientation: orientation, part: part, rights_holder: rights_holder,
  scale_bar: scale_bar, side: side, unit: unit, x_spacing: x_spacing, y_spacing: y_spacing, z_spacing: z_spacing) }

end
