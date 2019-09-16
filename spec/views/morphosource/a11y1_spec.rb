require "rails_helper"


feature "morphosource", :driver => :firefox_headless do
  background do
    visit 'https://www.morphosource.org/'
  end

  scenario "is known to be inaccessible, should fail" do
    expect(page).to be_accessible
  end
end
