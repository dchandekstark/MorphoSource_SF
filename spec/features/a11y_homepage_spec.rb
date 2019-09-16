require "rails_helper"

RSpec.feature "Accessibility check on homepage", :accessibility => true, :type => :feature, :driver => :firefox_headless do

  before(:each) do
    visit "/"
  end

  scenario "navbar-right should be accessible" do
    expect(page).to be_accessible.within '.navbar-right'
  end

  scenario "homepage should be accessible" do
    expect(page).to be_accessible
  end


end
