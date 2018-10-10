# Media Photogrammetry test
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a Media, Photogrammetry', js: true do
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
        fill_in('Title', with: 'My Rspec Test media')
        select('Medical X-Ray Computed Tomography (CT)', from: 'Modality')
        select('Photogrammetry image stack (multiple files of type *.tiff, *.png, etc.)', from: 'Media Type')
        
        click_on('Additional fields')
        fill_in('media_scale_bar_target_type', with: 'test')
        fill_in('media_scale_bar_distance', with: 'test')
        fill_in('media_scale_bar_units', with: 'test')
        fill_in('Element or Part', with: 'test')
        select('Left', from: 'Side')
        fill_in('Orientation', with: 'test')
        fill_in('Notes', with: 'test')
        fill_in('Keyword', with: 'test')
        fill_in('Identifier', with: 'test')
        fill_in('Related URL', with: 'test')
        fill_in('Creator', with: 'test')
        fill_in('Date Created', with: 'test')
        fill_in('Funding Attribution', with: 'test')
        select('Creative Commons BY-SA Attribution-ShareAlike 4.0 International', from: 'License')
        select('In Copyright - EU Orphan Work', from: 'Copyright Statement')
        fill_in('Additional Usage Agreement URL', with: 'test')
        fill_in('Rights Holder', with: 'test')
        fill_in('Cite As', with: 'test')
        fill_in('Publisher', with: 'test')
        
        # With selenium and the chrome driver, focus remains on the
        # select box. Click outside the box so the next line can't find
        # its element
        find('body').click
        choose('media_visibility_open')
        expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
        check('agreement')

        # scroll to the page bottom, otherwise will get the error "could not be scrolled into view" 
        page.execute_script "window.scrollBy(0,5000)"
        
        click_on('Save')
        # click to set focus again, otherwise content might not be found
        find('body').click
        expect(page).to have_content('My Rspec Test media')
    end
  end
end
