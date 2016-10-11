require 'spec_helper'

describe 'owner manages users' do

  it 'does not allow employees to manage users' do
    employee = log_in(create :user, :employee)
    page.should_not have_content 'Owner'
    visit '/manage/users'
    page.should have_content 'You do not have permission to'
  end

  it 'owner only sees users in the organization (multi-tenancy check)' do
    # Other owner and org
    owner1 = create :user, :owner
    org1 = owner1.organization
    org1.update_attributes!(:stripe_plan_id => 'Platinum', :stripe_customer_token => 'foobar')
    10.times { create :user, :employee, :organization_id => org1.id }

    # Tested owner and org
    owner2 = create :user, :owner
    org2 = owner2.organization
    org2.update_attributes!(:stripe_plan_id => 'Platinum', :stripe_customer_token => 'foobar')
    org2_users = 10.times.map { create :user, :employee, :organization_id => org2.id }

    log_in(owner2)
    visit '/manage/users'
    page.all('tbody tr').count.should == 11 # 10 users + 1 owner
    org2_users.each { |u| page.should have_content(u.last_name) }
  end

  it 'does not allow owner to create users when plan limit is reached' do
    owner = log_in(create :user, :owner)
    org = owner.organization
    org.update_attributes!(:stripe_plan_id => 'Silver', :stripe_customer_token => 'foobar')
    org.update_attribute(:num_allowed_users, org.plan.num_users)

    # Create users until the plan limit is hit (plan limit - owner user)
    (org.plan.num_users - 1).times do
      create :user, :employee, :organization_id => owner.organization.id
    end

    visit '/manage/users'
    click_on 'Add an Employee'
    page.should have_content 'Your account does not support additional users.'
  end

  it 'allows an inactive user to be made active when within plan limit' do
    owner = log_in(create :user, :owner)
    org = owner.organization
    org.update_attributes!(:stripe_plan_id => 'Silver', :stripe_customer_token => 'foobar', :num_allowed_users => 3)

    # Create inactive user
    inactive_user = create :user, :employee, :inactive, :organization_id => owner.organization_id

    visit "/manage/users/#{inactive_user.id}/edit"
    within "form#edit_user_#{inactive_user.id}" do
      check 'user_active'
      click_on 'Save User'
    end
    page.should have_content 'User updated successfully'
  end

  it 'does not allow an inactive user to be made active if plan limit is reached' do
    owner = log_in(create :user, :owner)
    org = owner.organization
    org.update_attributes!(:stripe_plan_id => 'Silver', :stripe_customer_token => 'foobar')

    # Create users until the plan limit is hit (plan limit - owner user)
    (org.plan.num_users - 1).times do
      create :user, :employee, :organization_id => owner.organization.id
    end
    # Create inactive user
    inactive_user = create :user, :employee, :inactive, :organization_id => owner.organization_id

    visit "/manage/users/#{inactive_user.id}/edit"
    within "form#edit_user_#{inactive_user.id}" do
      check 'user_active'
      click_on 'Save User'
    end
    page.should have_content "This organization's subscription does not allow for additional active users"
  end
end
