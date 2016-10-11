require 'spec_helper'

describe "proposals", :js => true do

  it 'allows employee to create a new proposal', :js => true do
    employee = log_in(create :user, :employee, :all_permissions)
    template = create :proposal_template, :organization_id => employee.organization.id
    job = create :job, :lead, :organization_id => employee.organization.id

    visit "/proposals/new?ptid=#{template.id}"

    page.should have_content 'New'
    page.execute_script("$('#proposal_job_id').show()")
    within '#new_proposal' do
      fill_in 'proposal_title', :with => 'Painting Project'
      select_from_chosen job.title, :from => 'proposal_job_id'
      fill_in 'proposal_license_number', :with => 'AB1532512'
      fill_in 'proposal_proposal_class', :with => 'Class 5'
      fill_in 'proposal_speciality', :with => 'Very Special'
      fill_in 'proposal_amount', :with => '114153'
      fill_in 'proposal_notes', :with => 'Blah blah blah'
      click_on 'Save Proposal'
    end

    page.should have_content 'Your proposal has been created successfully'
    page.should have_content 'Painting Project'
  end

  it 'locks a contract and proposal once accepted'
end
