require 'rails_helper'

RSpec.describe 'submissions/device_institution' do
  let(:ability) { double Ability }
  let(:new_institution_title) { ['XXYYZZ'] }

  before do
    assign(:submission, Submission.new)
		@institution_form = Hyrax::WorkFormService.build(Institution.new, ability, self)
	  session[:submission_institution_create_params] = ActionController::Parameters.new(title: new_institution_title)
	  render
  end

  describe 'device_institution_select partial' do
    it 'manually adds the new Institution to the select dropdown list' do
      expect(rendered).to match(/#{new_institution_title}/)
    end
  end

  describe 'device_institution_create partial' do
    let(:partial_content) { 'device_institution_create partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_device_institution_create.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end

end
