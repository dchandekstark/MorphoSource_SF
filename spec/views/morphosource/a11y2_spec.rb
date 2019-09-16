require "rails_helper"

RSpec.feature "Accessibility check on Search Result page", :type => :feature, :driver => :firefox_headless do

  before(:each) do
    visit "/"
    fill_in "search-field-header", with: 'abc'
    click_button "Go"
	end

  scenario "Top navigation should be accessible" do

    expect(page).to be_accessible.within '.navbar'

  end

  scenario "Labels within Content should be accessible" do

  	expect(page).to be_accessible.within('#content').checking_only :label

  end

end
