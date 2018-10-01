# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a Media', js: true do
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
      choose "payload_concern", option: "Media"
      click_button "Create work"

      expect(page).to have_content "Add New Media"

      fill_in('Title', with: 'My Test Media Work')
      select('Positron Emission Tomography (PET)', from: 'Modality')
      select('Photogrammetry image stack (multiple files of type *.tiff, *.png, etc.)', from: 'Media Type')

      # Use JS to fill in hidden fields
      page.execute_script("
        document.getElementById('media_scale_bar_target_type').value = 'Example Target Type';
        document.getElementById('media_scale_bar_distance').value = 'Example Distance';
        document.getElementById('media_scale_bar_units').value = 'Example Units';
      ");

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element
      find('body').click

      choose('media_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      check('agreement')
      click_on('Save')

      expect(page).to have_content('My Test Media Work')
      expect(page).to have_content("Type: Example Target Type, Distance: Example Distance, Units: Example Units")

      click_link 'Edit'

      click_link 'Additional fields'

      expect(page).to have_field("media_scale_bar_target_type", with: 'Example Target Type')
      expect(page).to have_field("media_scale_bar_distance", with: 'Example Distance')
      expect(page).to have_field("media_scale_bar_units", with: 'Example Units')

    end
  end
end
