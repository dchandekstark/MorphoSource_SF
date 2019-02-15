require 'rails_helper'

RSpec.describe 'submissions/_cho_search', type: :view do
  let(:submission) { Submission.new }
  let(:form_template) do
    %(
      <%= simple_form_for @submission do |f| %>
        <%= render 'submissions/cho_search', f: f %>
      <% end %>
    )
  end
  let(:page) do
    assign(:submission, submission)
    render inline: form_template
    Capybara::Node::Simple.new(rendered)
  end
  it 'displays the biological specimen search form' do
    expect(page).to have_content(I18n.t('morphosource.submission.cho_search'))
    expect(page).to have_field(I18n.t('simple_form.labels.submission.cho_search_occurrence_id'))
    expect(page).to have_field(I18n.t('simple_form.labels.submission.cho_search_institution_code'))
    expect(page).to have_field(I18n.t('simple_form.labels.submission.cho_search_collection_code'))
    expect(page).to have_field(I18n.t('simple_form.labels.submission.cho_search_catalog_number'))
  end
end
