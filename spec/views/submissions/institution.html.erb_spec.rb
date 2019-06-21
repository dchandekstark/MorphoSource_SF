require 'rails_helper'

RSpec.describe 'submissions/institution' do
  let(:ability) { double Ability }

  before do
		@institution_form = Hyrax::WorkFormService.build(Institution.new, ability, self)
  end

  describe 'institution_select partial' do
    let(:partial_content) { 'institution_select partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_institution_select.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end
  describe 'institution_create partial' do
    let(:partial_content) { 'institution_create partial content' }
    it 'renders the partial' do
      assign(:submission, Submission.new)
      stub_template 'submissions/_institution_create.html.erb' => partial_content
      render
      expect(rendered).to match(/#{partial_content}/)
    end
  end

end
