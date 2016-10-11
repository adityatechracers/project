require 'spec_helper'

describe 'owner manages crews' do

  it 'does not allow employees to manage crews' do
    employee = log_in(create :user, :employee)
    page.should_not have_content 'Manage'
    visit '/manage/crews'
    page.should have_content 'You do not have permission to'
  end

  it 'allows owner to create a new crew' do
    owner = log_in(create :user, :owner)
    org = owner.organization
    employees = 5.times.map { create :user, :employee, :organization_id => org.id }

    visit '/manage/crews'
    click_on 'New Crew'

    within '#new_crew' do
      fill_in 'crew_name', :with => 'Alpha Squad'
      select employees[0].name, :from => 'crew_user_ids'
      select employees[2].name, :from => 'crew_user_ids'
      select employees[4].name, :from => 'crew_user_ids'
      click_on 'Save Crew'
    end

    page.should have_content 'The crew has been created'

    Crew.last.users.count.should == 3
    Crew.last.users.should include(employees[0])
    Crew.last.users.should include(employees[2])
    Crew.last.users.should include(employees[4])
  end

  it 'allows owner to edit a crew' do
    owner = log_in(create :user, :owner)
    org = owner.organization
    employees = 5.times.map { create :user, :employee, :organization_id => org.id }
    new_employee = create :user, :employee, :organization_id => org.id
    crew = create :crew, :organization_id => org.id, :users => employees

    visit '/manage/crews'
    page.should have_content crew.name
    crew_row = find('tr', :text => crew.name)

    visit "/manage/crews/#{crew.id}/edit"

    page.should have_content 'Edit'
    within "#edit_crew_#{crew.id}" do
      fill_in 'crew_name', :with => 'Delta Squad'
      select new_employee.name, :from => 'crew_user_ids'
      click_on 'Save Crew'
    end

    Crew.last.users.count.should == 6
    Crew.last.users.should include(new_employee)
    employees.each { |e| Crew.last.users.should include(e) }
  end
end
