require 'spec_helper'

describe "the signup process" do

  it "creates an account", js: true do
    visit '/users/sign_up'
    within('#new_user') do
      fill_in "user_first_name", :with => "Test"
      fill_in "user_last_name", :with => "User"
      fill_in "user_email", :with => "user2@example.com"
      fill_in "user_password", :with => "testtest"
      fill_in "user_password_confirmation", :with => "testtest"
      fill_in "user_organization_name", :with => "Test Org 2"
      check 'user_terms_of_service'
      click_on "Start Your Free Trial"
    end
    Organization.where(:name => 'Test Org 2').count.should == 1
    find('.subnav_list.active').should have_content('Dashboard')
    click_on 'Logout'
    page.should have_content 'Signed out successfully.'
  end

  it 'signs the user in', js: true do
    u = create :user, :employee
    visit '/users/sign_in'
    within('#new_user') do
      fill_in "Email", :with => u.email
      fill_in "Password", :with => u.password
      click_on "Login"
    end
    page.should have_content 'Signed in successfully'
    on_page? 'Dashboard'
  end

  it "allows user to sign in, change subscription and logout", js: true do
    user = create :user, :owner
    org = user.organization
    visit '/users/sign_in'
    within('#new_user') do
      fill_in "Email", :with => user.email
      fill_in "Password", :with => user.password
      click_on "Login"
    end
    page.should have_content 'Signed in successfully'
    find('.subnav_list.active').should have_content 'Dashboard'

    # Set subscription
    visit "/manage/subscription"
    page.execute_script("$('#subscription_form_wrapper').show()")
    click_on "Upgrade to Gold"
    within "#edit_organization_#{org.id}" do
      fill_in "organization_name_on_credit_card", :with => user.name
      fill_in "card_number", :with => "4242 4242 4242 4242"
      fill_in "card_code", :with => "123"
      select "2018", :from => "card_year"
      click_on "Update Your Subscription"
    end
    page.execute_script("$('#subscription_form_wrapper input[type=submit]').click()")
    sleep(4)
    page.should have_content 'Subscription successfully updated!'

    # Logout
    click_on 'Logout'
    page.should have_content 'Signed out successfully.'
  end
end
