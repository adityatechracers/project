require 'spec_helper'

module AuthHelpers
  def log_in_with(email, password)
    visit '/users/sign_in'
    within('#new_user') do
      fill_in 'user_email', :with => email
      fill_in 'user_password', :with => password
      click_on 'Login'
    end
  end

  def log_in(user)
    visit '/users/sign_in'
    within('#new_user') do
      fill_in 'user_email', :with => user.email
      fill_in 'user_password', :with => user.password
      click_on 'Login'
    end
    user
  end

  def create_and_log_in_with(email, password, options)
    options[:email], options[:password] = email, password
    u = User.where(:email => email).any? ? User.find_by_email(email) : create(:user, options)
    log_in_with(email, password)
    return u
  end

  def log_out
    click_on 'Logout'
    page.should have_content 'Signed out successfully.'
  end
end
