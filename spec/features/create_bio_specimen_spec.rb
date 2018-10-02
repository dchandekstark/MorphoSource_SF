# Generated via
#  `rails generate hyrax:work PhysicalObject`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a PhysicalObject', js: true do
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
      choose "payload_concern", option: "PhysicalObject"
      click_button "Create work"

      expect(page).to have_content "Add New Physical Object"

      fill_in('Title', with: 'My Test Physical Object')
      select('Yes', from: 'Vouchered?')
      select('Biological Specimen', from: 'Resource Type')

      # Use JS to fill in hidden fields
      page.execute_script("
        document.getElementById('physical_object_idigbio_recordset_id').value = 'AAAAbbbb';
        document.getElementById('physical_object_idigbio_uuid').value = '1234abcd';
        document.getElementById('physical_object_is_type_specimen').value = 'Yes';
        document.getElementById('physical_object_occurrence_id').value = 'ABCD1234';
        document.getElementById('physical_object_sex').value = 'Female';
      ");

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can find
      # its element
      find('body').click

      choose('physical_object_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      check('agreement')
      click_on('Save')
      expect(page).to have_content('My Test Physical Object')

      click_link 'Edit'

      click_link 'Additional fields'

      expect(page).to have_field('physical_object_idigbio_recordset_id', with: 'AAAAbbbb')
      expect(page).to have_field('physical_object_idigbio_uuid', with: '1234abcd')
      expect(page).to have_field('physical_object_is_type_specimen', with: 'Yes')
      expect(page).to have_field('physical_object_occurrence_id', with: 'ABCD1234')
      expect(page).to have_field('physical_object_sex', with: 'Female')

    end
  end
end
