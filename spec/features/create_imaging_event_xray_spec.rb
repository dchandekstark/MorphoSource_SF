# ICE Xray test
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a ImagingEvent, Xray modality type', js: true do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    before do
      # Create a single action that can be taken
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'user',
        agent_id: user.user_key,
        access: 'deposit'
      )
      login_as user
    end

    scenario do
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"

      # If you generate more than one work uncomment these lines
      choose "payload_concern", option: "ImagingEvent"
      click_button "Create work"

      expect(page).to have_content "Add New Imaging Event"
      #click_link "Files" # switch tab
      #expect(page).to have_content "Add files"
      #expect(page).to have_content "Add folder"
      #within('span#addfiles') do
      #$attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/image.jp2", visible: false)
      #attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/jp2_fits.xml", visible: false)
      #end
      #click_link "Descriptions" # switch tab

      fill_in('Title', with: 'My Rspec Test imaging event')
      select('Medical X-Ray Computed Tomography (CT)', from: 'Scanner Modality')

      fill_in('Creator', with: 'Doe, Jane')
      fill_in('Software', with: 'software spec 1')
      fill_in('Exposure time', with: 'exposure time 1 spec')
      select('Yes', from: 'Flux normalization')
      select('Yes', from: 'Geometric calibration')
      select('Yes', from: 'Shading correction')
      select('Lead', from: 'Filter material')
      fill_in('imaging_event_filter_thickness', with: '999')
      fill_in('Frame averaging', with: 'test test')
      fill_in('Projections', with: 'test test')
      fill_in('Voltage', with: 'test test')
      fill_in('Power', with: 'test test')
      fill_in('Amperage', with: 'test test')
      fill_in('Surrounding material', with: 'test test')
      fill_in('Xray tube type', with: 'test test')
      select('Reflection', from: 'Target type')
      select('Direct (X-Ray photoconductor)', from: 'Detector type')
      select('Area (single or tiled detector)', from: 'Detector configuration')
      fill_in('Source object distance', with: 'test test')
      fill_in('Source detector distance', with: 'test test')
      fill_in('Target material', with: 'test test')
      fill_in('Rotation number', with: 'test test')
      select('No', from: 'Phase contrast')
      select('No', from: 'Optical magnification')

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element
      find('body').click
      choose('imaging_event_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      check('agreement')

      # scroll to the page bottom, otherwise will get the error "could not be scrolled into view" 
      page.execute_script "window.scrollBy(0,5000)"

      click_on('Save')
      # click to set focus again, otherwise content might not be found
      find('body').click
      expect(page).to have_content('My Rspec Test imaging event')
      # verify the Filter value is concatenated from Filter material and filter thickness
      expect(page).to have_content('Filter material: Lead, Filter thickness: 999') 
    end
  end
end
