require 'spec_helper'
require 'ffaker'

describe 'admin panel' do

  before(:each) do
    @admin = create :user, :admin, :admin_can_manage_accounts => true
  end

  it 'redirects to the users page after sign in', js: true do
    visit '/users/sign_in'
    within('#new_user') do
      fill_in 'user_email', :with => @admin.email
      fill_in 'user_password', :with => @admin.password
      click_on 'Login'
    end
    page.should have_content('Signed in successfully')
    page.should have_content('Users')
    on_page? 'Admin'
    click_on 'Logout'
    page.should have_content('Signed out successfully.')
  end

  it 'displays all users within the system' do
    a = create :user, :admin
    users = 5.times.map { create :user, :employee }
    log_in_with(@admin.email, @admin.password)
    visit '/admin/users'
    within('.widget') do
      page.should have_content('Users')
      users.each do |u|
        page.should have_content(u.last_name)
        page.should have_content(u.email)
      end
    end
  end

  it 'displays all organizations within the system' do
    orgs = 5.times.map { create(:user, :owner).organization }.map(&:reload)
    log_in_with(@admin.email, @admin.password)
    visit '/admin/organizations'
    within('.widget') do
      page.should have_content 'Organizations'
      page.all('tbody tr').count.should == 5
      orgs.each do |o|
        tr = page.find('td', :text=> o.name).parent
        tr.should have_content(o.owner.name)
        tr.should have_content(o.stripe_plan_id)
      end
    end
  end
end
