require 'spec_helper'

describe 'owner manages proposal templates' do

  it 'does not allow employees to manage proposal templates' do
    employee = log_in(create(:user, :employee))
    page.should_not have_content('Owner')
    visit '/manage/proposal_templates'
    page.should have_content('You do not have permission to')
  end

  it 'clones master templates for new organization' do
    template1 = create :proposal_template, :master
    template2 = create :proposal_template, :master
    visit '/users/sign_up'
    within '#new_user' do
      fill_in 'user_first_name', :with => 'Stan'
      fill_in 'user_last_name', :with => 'Sitwell'
      fill_in 'user_email', :with => 'stan@sitwellindustries.com'
      fill_in 'user_password', :with => 'standpoor'
      fill_in 'user_password_confirmation', :with => 'standpoor'
      fill_in 'user_organization_name', :with => 'Sitwell Industries'
      check 'user_terms_of_service'
      click_on 'Start Your Free Trial'
    end
    visit '/manage/proposal_templates'
    page.should have_content('New Proposal Template')
    page.should have_content(template1.name)
    page.should have_content(template2.name)
  end

  it 'allows owner to view proposal template listing' do
    owner = create(:user, :owner)
    templates = 10.times.map do
      create :proposal_template, :organization_id => owner.organization.id
    end
    log_in(owner)
    visit '/manage/proposal_templates'
    page.should have_content('New Proposal Template')
    templates.each { |t| page.should have_content(t.name) }
  end

  it 'allows owner to create a new proposal template' do
    owner = log_in(create(:user, :owner))
    visit '/manage/proposal_templates'

    # New template
    click_on 'New Proposal Template'
    within('#new_proposal_template') do
      fill_in 'proposal_template_name', :with => 'Some Template'
      click_on 'Save'
    end
    page.should have_content('The proposal template has been created')
    ProposalTemplate.last.name.should eq('Some Template Proposal')

    # New section within template
    click_on 'Add Section'
    within('#new_proposal_template_section') do
      fill_in 'proposal_template_section_name', :with => 'Preparation'
      fill_in 'proposal_template_section_background_color', :with => '#FF0'
      fill_in 'proposal_template_section_foreground_color', :with => '#FFF'
      fill_in 'proposal_template_section_default_description', :with => 'the description'
      check 'proposal_template_section_show_include_exclude_options'
      fill_in 'proposal_template_section_position', :with => '1'
      click_on 'Save'
    end
    within('.proposal-template-section') do
      page.should have_content('Preparation')
      page.should have_content('the description')
    end

    # New item within section
    find('.add-item-btn').click
    within('#new_proposal_template_item') do
      fill_in 'proposal_template_item_name', :with => 'Caulking'
      fill_in 'proposal_template_item_default_note_text', :with => 'Around the sides of building'
      fill_in 'proposal_template_item_help_text', :with => 'Some help text'
      choose 'proposal_template_item_default_include_exclude_option_include'
      click_on 'Save'
    end
    within('.proposal-template-section') do
      page.should have_content('Caulking')
      page.should have_content('Some help text')
      page.should have_content('Include')
      page.should have_content('Exclude')
      page.should have_css("input[checked][name='Caulking']")
    end
  end

  it 'allows owner to add sections to an existing proposal template' do
    owner = create(:user, :owner)
    template = create :proposal_template, :organization_id => owner.organization.id

    log_in(owner)
    visit '/manage/proposal_templates'

    click_on template.name

    click_on 'Add Section'
    within('#new_proposal_template_section') do
      fill_in 'proposal_template_section_name', :with => 'Cleanup'
      fill_in 'proposal_template_section_background_color', :with => '#FF0'
      fill_in 'proposal_template_section_foreground_color', :with => '#FFF'
      fill_in 'proposal_template_section_default_description', :with => 'the description'
      check 'proposal_template_section_show_include_exclude_options'
      fill_in 'proposal_template_section_position', :with => '1'
      click_on 'Save'
    end
    within('.proposal-template-section') do
      page.should have_content('Cleanup')
      page.should have_content('the description')
    end
  end

  it 'allows owner to delete a section', :js => true do
    owner = create(:user, :owner)
    template = create :proposal_template, :with_sections, :organization_id => owner.organization.id

    log_in(owner)
    visit '/manage/proposal_templates'

    click_on template.name
    section = all('h3', :text => template.section_templates.first.name.upcase).first
    within(section) do
      # Rescue javascript errors due to ckeditor double instantiation. Seems to be a phantomjs issue.
      find('.edit-section-btn').click rescue Capybara::Poltergeist::JavascriptError
    end

    without_confirm_dialog { click_on 'Delete' }
    page.should have_content('The proposal template section has been deleted')
  end

  it "doesn't allow invalid Liquid syntax" do
    owner = create(:user, :owner)

    # Create and update proposal template with bad syntax
    template = create :proposal_template, :organization_id => owner.organization.id
    log_in(owner)
    visit "/manage/proposal_templates/#{template.id}/edit_contract"
    within("#edit_proposal_template_#{template.id}") do
      fill_in 'Contract Agreement', :with => "This is a test of bad templating syntax, such as {{customer_phone_number}."
      click_on 'Save Contract'
    end

    page.should have_content('was not properly terminated with regexp')
  end
end
