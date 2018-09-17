# Generated via
#  `rails generate hyrax:work PhysicalObject`
require 'rails_helper'

RSpec.describe Hyrax::PhysicalObjectPresenter do
  subject(:presenter) { described_class.new(SolrDocument.new(work.to_solr), nil) }

  let(:bibliographic_citation)  {['example citation']}
  let(:catalog_number)          {['example catalog number']}
  let(:collection_code)         {['example collection code']}
  let(:based_near)              {["London"]}
  let(:date_created)            {['free text date created']}
  let(:description)             {['example description']}
  let(:identifier)              {['1234ABCD']}
  let(:institution)             {['Duke University']}
  let(:numeric_time)            {['30 years']}
  let(:original_location)       {['Rome, Italy']}
  let(:periodic_time)           {['18th century']}
  let(:physical_object_type)    {['CHO']}
  let(:publisher)               {['Random House']}
  let(:related_url)             {['www.google.com']}
  let(:vouchered)               {['Yes']}

  #Biological only
  let(:idigbio_recordset_id)    {['example recordset id']}
  let(:idigbio_uuid)            {['example uuid']}
  let(:is_type_specimen)        {['Yes']}
  let(:occurrence_id)           {['ABCD1234']}
  let(:sex)                     {['Male']}

  #CHOs only
  let(:title)                   {['Parthenon']}
  let(:contributor)             {['example contributor']}
  let(:creator)                 {['example creator']}
  let(:material)                {['marble']}
  let(:cho_type)                {['temple']}

  let(:visibility)              { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:user)                    { 'test@example.com' }

  let :work do
    PhysicalObject.create(catalog_number:         catalog_number,
                          title:                  title,
                          bibliographic_citation: bibliographic_citation,
                          collection_code:        collection_code,
                          based_near:             based_near,
                          date_created:           date_created,
                          description:            description,
                          identifier:             identifier,
                          institution:            institution,
                          numeric_time:           numeric_time,
                          original_location:      original_location,
                          periodic_time:          periodic_time,
                          physical_object_type:   physical_object_type,
                          publisher:              publisher,
                          related_url:            related_url,
                          vouchered:              vouchered,

                          #Biological only
                          idigbio_recordset_id:   idigbio_recordset_id,
                          idigbio_uuid:           idigbio_uuid,
                          is_type_specimen:       is_type_specimen,
                          occurrence_id:          occurrence_id,
                          sex:                    sex,

                          #CHOs only
                          contributor:            contributor,
                          creator:                creator,
                          material:               material,
                          cho_type:               cho_type)
  end

  it { is_expected.to have_attributes(based_near_label: based_near, sex: sex, title: title, vouchered: vouchered, bibliographic_citation: bibliographic_citation, related_url: related_url, catalog_number: catalog_number, collection_code: collection_code, date_created: date_created, description: description, identifier: identifier, institution: institution, numeric_time: numeric_time, original_location: original_location, periodic_time: periodic_time, physical_object_type: physical_object_type, publisher: publisher, idigbio_recordset_id: idigbio_recordset_id, idigbio_uuid: idigbio_uuid, is_type_specimen: is_type_specimen, occurrence_id: occurrence_id, contributor: contributor, creator: creator, material: material, cho_type: cho_type) }

end
