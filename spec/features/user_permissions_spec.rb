# encoding: UTF-8
require 'spec_helper'

describe 'user permissions' do

  it 'allows user to view leads when permitted' do
    org = create(:organization, :with_owner)
    u = create(:user, role: 'Employee', can_view_leads: true, organization_id: org.id)
    log_in(u)
    jobs = 5.times.map { create :job, :lead, organization_id: u.organization.id }

    visit '/leads'
    jobs.each do |j|
      page.should have_content(j.contact.backwards_name)
    end
  end

  it 'stops user from viewing leads when not permitted' do
    org = create(:organization, :with_owner)
    u = create(:user, role: 'Employee', can_view_leads: false, organization_id: org.id)
    log_in(u)
    jobs = 5.times.map { create :job, :lead, organization_id: u.organization.id }

    visit '/leads'
    page.should have_content 'You do not have permission to access this area or content.'
    current_page.should have_content 'Dashboard'
  end

  it 'allows user to manage leads when permitted' do
    org = create(:organization, :with_owner)
    u = create(:user, role: 'Employee', can_manage_leads: true, organization_id: org.id)
    log_in(u)
    jobs = 5.times.map { create :job, :lead, organization_id: u.organization.id }

    visit new_lead_path
    current_page.should have_content 'Leads'
  end

  it 'stops user from managing leads when not permitted' do
    org = create(:organization, :with_owner)
    u = create(:user, role: 'Employee', organization_id: org.id, can_manage_leads: false)
    log_in(u)
    jobs = 5.times.map { create :job, :lead, organization_id: u.organization.id }

    visit new_lead_path
    page.should have_content 'You do not have permission to access this area or content.'
    current_page.should have_content 'Dashboard'
  end

  it 'allows user to view all jobs when permitted' do
    org = create(:organization, :with_owner)
    other_org = create(:organization, :with_owner)
    u = create(:user, role: 'Employee', organization_id: org.id, can_view_all_jobs: true)

    log_in(u)
    ActsAsTenant.with_tenant(nil) do
      all_jobs = 5.times.map { create :job, :with_accepted_proposal, organization_id: other_org.id }
      org_jobs = 4.times.map { create :job, :with_accepted_proposal, organization_id: u.organization.id }
    end

    visit '/jobs'
    page.should have_content 'Jobs'
    page.all('tbody tr').count.should == 4

    within('.widget-header') { click_on 'Schedule' }
    page.should have_content 'Jobs»Schedule'
    page.should_not have_content 'Schedule a Job' # Can't manage jobs
  end

  it 'allows user to view own (but not all) jobs when permitted' do
    org = create(:organization, :with_owner)
    other_org = create(:organization, :with_owner)
    user = create(:user, role: 'Employee', organization_id: org.id, can_view_own_jobs: true)
    crew = create(:crew, users: [user], organization_id: user.organization.id)

    # User should see jobs that they are either assigned to or whose crew is one of the user's crews.
    non_org_jobs  = 5.times.map { create :job, :with_accepted_proposal, organization_id: other_org.id }
    org_jobs      = 5.times.map { create :job, :with_accepted_proposal, organization_id: user.organization.id }
    crew_jobs     = 3.times.map { create :job, :with_accepted_proposal, organization_id: user.organization.id, crew_id: crew.id }
    assigned_jobs = 4.times.map { create :job, :with_accepted_proposal, organization_id: user.organization.id, users: [user] }

    log_in(user)
    visit '/jobs'
    page.should have_content 'Jobs'

    table = page.find('tbody')
    table.all('tr').count.should == 7

    crew_jobs.each { |j| table.should have_content(j.title) }
    assigned_jobs.each { |j| table.should have_content(j.title) }

    visit '/jobs/schedule'
    page.should have_content 'Jobs»Schedule'
    page.should_not have_content 'Schedule a Job' # Can't manage jobs
  end

  it 'stops user from viewing any jobs when not permitted' do
    org = create(:organization, :with_owner)
    user = create(:user, role: 'Employee', organization_id: org.id) # No permissions set by default
    crew = create(:crew, users: [user], organization_id: user.organization.id)

    crew_jobs     = 3.times.map { create :job, :with_accepted_proposal, organization_id: user.organization.id, crew_id: crew.id }
    assigned_jobs = 4.times.map { create :job, :with_accepted_proposal, organization_id: user.organization.id, users: [user] }

    log_in(user)
    visit '/jobs'
    page.should have_content 'You do not have permission to access this area or content.'
  end

  it 'allows user to view appointments when permitted' do
    org = create(:organization, :with_owner)
    user = log_in(create(:user, role: 'Employee', organization_id: org.id, can_view_appointments: true))
    visit '/appointments'
    page.should have_content 'Schedule Appointments'
    page.should_not have_content 'Add an Appointment'
  end

  it 'stops user from viewing appointments when not permitted' do
    org = create(:organization, :with_owner)
    user = log_in(create(:user, role: 'Employee', can_view_appointments: false, organization_id: org.id))
    visit '/appointments'
    page.should have_content 'You do not have permission to access this area or content.'
  end

  it 'allows user to manage appointments when permitted' do
    org = create(:organization, :with_owner)
    user = log_in(create(:user, role: 'Employee', can_manage_appointments: true, organization_id: org.id))
    # We're cheating a bit here to avoid interacting with the calendar
    # Should verify the behavior manually too.
    visit '/appointments/modal'
    page.should have_content 'New Appointment'
  end

  it 'stops user from managing appointments when not permitted' do
    org = create(:organization, :with_owner)
    user = log_in(create(:user, role: 'Employee', can_manage_appointments: false, organization_id: org.id))
    visit '/appointments/modal'
    page.should have_content 'You do not have permission to access this area or content.'
  end

  it 'allows user to view all proposals when permitted' do
    org = create(:organization, :with_owner)
    other_org = create(:organization, :with_owner)
    user = create(:user, role: 'Employee', can_view_all_proposals: true, organization_id: org.id)

    ActsAsTenant.with_tenant(nil) do
      proposals     = 3.times.map { create :proposal, :with_job, organization_id: other_org.id }
      org_proposals = 4.times.map { create :proposal, :with_job, organization_id: org.id }
    end

    log_in(user)
    visit '/proposals'
    page.all('tbody tr').count.should == 4
  end

  it 'allows user to view own proposals when permitted' do
    other_org = create(:organization, :with_owner)
    org = create(:organization, :with_owner)
    user = create(:user, role: 'Employee', can_view_assigned_proposals: true, organization_id: org.id)

    proposals     = 3.times.map { create :proposal, :with_job, organization_id: other_org.id }
    org_proposals = 4.times.map { create :proposal, :with_job, organization_id: user.organization.id }
    own_proposals = 5.times.map { create :proposal, :with_job, organization_id: user.organization.id, sales_person_id: user.id } +
                    5.times.map { create :proposal, :with_job, organization_id: user.organization.id, contractor_id: user.id }

    log_in(user)
    visit '/proposals'
    page.all('tbody tr').count.should == 10
  end

  it 'stops user from viewing any proposals when not permitted' do
    org = create(:organization, :with_owner)
    user = create(:user, role: 'Employee', organization_id: org.id) # No permissions set by default
    own_proposals = 5.times.map { create :proposal, :with_job, organization_id: user.organization.id, sales_person_id: user.id } +
                    5.times.map { create :proposal, :with_job, organization_id: user.organization.id, contractor_id: user.id }

    log_in(user)
    visit '/proposals'
    page.should have_content 'You do not have permission to access this area or content.'
  end

  it 'allows user to manage all proposals when permitted' do
    org = create(:organization, :with_owner)
    user = create(:user, role: 'Employee', can_manage_proposals: true, can_view_all_proposals: true, organization_id: org.id)
    proposal_template = create :proposal_template, organization_id: user.organization.id
    proposal = create :proposal, :with_job, :unsigned, organization_id: user.organization.id,
                      proposal_template_id: proposal_template.id, proposal_state: 'Active'
    log_in(user)
    visit "/proposals/#{proposal.guid}/edit"
    page.should have_content 'Edit'
  end

  it 'allows user to manage own proposals when permitted' do
    org = create(:organization, :with_owner)
    user = create(:user, role: 'Employee', can_manage_proposals: true, can_view_assigned_proposals: true, organization_id: org.id)
    proposal_template = create :proposal_template, organization_id: user.organization.id
    assigned_proposal = create :proposal, :with_job, :unsigned, organization_id: user.organization.id,
                               proposal_template_id: proposal_template.id, sales_person_id: user.id,
                               proposal_state: 'Active'
    org_proposal = create :proposal, :with_job, organization_id: user.organization.id,
                          proposal_template_id: proposal_template.id, proposal_state: 'Active'
    log_in(user)

    # Can view assigned proposal
    visit "/proposals/#{assigned_proposal.guid}/edit"
    page.should have_content 'Edit'

    # But not a organization proposal they are not explicitly assigned to.
    visit "/proposals/#{org_proposal.guid}/edit"
  end

  it 'stops user from managing any proposals when not permitted' do
    org = create(:organization, :with_owner)
    user = create(:user, role: 'Employee', organization_id: org.id) # No permissions set by default
    assigned_proposal = create :proposal, :with_job, :unsigned, organization_id: user.organization.id,
                               sales_person_id: user.id, proposal_state: 'Active'
    log_in(user)
    visit "/proposals/#{assigned_proposal.guid}/edit"
    page.should have_content 'You do not have permission to access this area or content.'
  end
end
