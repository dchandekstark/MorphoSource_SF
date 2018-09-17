require 'rails_helper'

RSpec.feature 'Display a Physical Object Work' do
  let(:bibliographic_citation)  {['example citation']}
  let(:catalog_number)          {['example catalog number']}
  let(:collection_code)         {['example collection code']}
  let(:based_near)              {['http://sws.geonames.org/2231835/']}
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
    PhysicalObject.create(title:                  title,
                          bibliographic_citation: bibliographic_citation,
                          catalog_number:         catalog_number,
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
                          cho_type:               cho_type,

                          visibility:             visibility,
                          depositor:              user)
  end

  scenario "Show a public Work" do
    visit("/concern/physical_objects/#{work.id}")

    expect(page).to have_content work.bibliographic_citation.first
    expect(page).to have_content work.catalog_number.first
    expect(page).to have_content work.collection_code.first
    expect(page).to have_content work.based_near.first
    expect(page).to have_content work.date_created.first
    expect(page).to have_content work.description.first
    expect(page).to have_content work.identifier.first
    expect(page).to have_content work.institution.first
    expect(page).to have_content work.numeric_time.first
    expect(page).to have_content work.original_location.first
    expect(page).to have_content work.periodic_time.first
    expect(page).to have_content work.physical_object_type.first
    expect(page).to have_content work.publisher.first
    expect(page).to have_content work.related_url.first
    expect(page).to have_content work.vouchered.first

    #Biological only
    expect(page).to have_content work.idigbio_recordset_id.first
    expect(page).to have_content work.idigbio_uuid.first
    expect(page).to have_content work.is_type_specimen.first
    expect(page).to have_content work.occurrence_id.first
    expect(page).to have_content work.sex.first

    #CHOs only
    expect(page).to have_content work.title.first
    expect(page).to have_content work.contributor.first
    expect(page).to have_content work.creator.first
    expect(page).to have_content work.material.first
    expect(page).to have_content work.cho_type.first

  end
end
