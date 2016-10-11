require 'spec_helper'

describe 'organization subscriptions', :js => true do

  pending 'owner changes subscription plan' do
    owner = log_in(create :user, :owner)

    # Set subscription
    org = owner.organization
    visit "/manage/subscription"
    page.execute_script("$('#subscription_form_wrapper').show()")
    click_on "Upgrade to Gold"
    within("#edit_organization_#{org.id}") do
      fill_in "organization_name_on_credit_card", :with => owner.name
      fill_in "card_number", :with => "4242 4242 4242 4242"
      fill_in "card_code", :with => "123"
      select "2017", :from => "card_year"
      click_on "Update Your Subscription"
    end
    sleep 5
    page.should have_content 'Subscription successfully updated!'
  end

  it 'does not show the subscription page to organization employees' do
    employee = log_in(create :user, :employee)
    page.should_not have_content 'My Subscription'
    visit '/manage/subscription'
    page.should have_content 'You do not have permission to'
  end

  it 'allows the owner to cancel the subscription', :js => true do
    pending('skipping unreliable spec for now') if ENV['USER'] == 'jenkins'

    owner = log_in(create :user, :owner)

    # Set subscription
    org = owner.organization
    visit "/manage/subscription"
    page.execute_script("$('#subscription_form_wrapper').show()")
    within("#edit_organization_#{org.id}") do
      fill_in "organization_name_on_credit_card", :with => owner.name
      fill_in "card_number", :with => "4242 4242 4242 4242"
      fill_in "card_code", :with => "123"
      select "2017", :from => "card_year"
      click_on "Update Your Subscription"
    end
    sleep 5
    page.should have_content 'Subscription successfully updated!'

    # Seed email template
    create :email_template, :name => 'cancelled-paid-account', :master => true

    # Cancel
    without_confirm_dialog { click_on 'Cancel Subscription' }
    page.should have_content 'Your account has been deactivated.'
    page.should_not have_content 'Cancel Subscription'

    org = Organization.find(org.id)
    org.active.should == false
    org.stripe_plan_id.should be_nil

    # Try to use account
    visit '/leads'
    page.should have_content 'This account is not active. Select a plan to keep using CorkCRM.'
    page.should have_content 'Edit Subscription'
  end

  it 'allows the owner of a cancelled organization to re-subscribe' do
    owner = create :user, :owner
    org = owner.organization
    org.update_attributes!(:active => false, :stripe_plan_id => nil, :stripe_customer_token => nil)

    log_in(owner)
    page.execute_script("$('#subscription_form_wrapper').show()")
    within("#edit_organization_#{org.id}") do
      fill_in "organization_name_on_credit_card", :with => owner.name
      fill_in "card_number", :with => "4242 4242 4242 4242"
      fill_in "card_code", :with => "123"
      select "2017", :from => "card_year"
      click_on "Update Your Subscription"
    end
    sleep 5
    page.should have_content 'Subscription successfully updated!'

    visit '/leads'
    page.should_not have_content 'Edit Subscription'
  end

  it 'redirects owner with cancelled subscription to subscriptions page on login' do
    owner = create :user, :owner
    org = owner.organization
    org.update_attributes!(:active => false, :stripe_plan_id => nil, :stripe_customer_token => nil)

    log_in(owner)
    page.should have_content 'This account is not active. Select a plan to keep using CorkCRM.'
    page.should have_content 'Edit Subscription'

    visit '/leads'
    page.should have_content 'This account is not active. Select a plan to keep using CorkCRM.'
    page.should have_content 'Edit Subscription'
  end

  it 'locks out employee under org with cancelled subscription' do
    employee = create :user, :employee
    org = employee.organization
    org.update_attributes!(:active => false, :stripe_plan_id => nil, :stripe_customer_token => nil)

    log_in(employee)
    page.should have_content 'Your account is not activated.'
  end

  context 'failed payment flow' do
    before :each do
      ActionMailer::Base.deliveries = []
      ActiveRecord::Base.connection.execute("INSERT INTO email_templates
                                            (organization_id, name, subject, body, enabled, master, created_at, updated_at, description, lang, mail_to_cc)
                                            VALUES (NULL, 'failed-payment-reminder', 'CorkCRM: Failed Payment Reminder', '<span style=\"font-size:14px;\">CorkCRM was unable to charge to your credit card. You have {{days}} day(s) until your account can no longer use our service.<br />
                                            <br />
                                            If you have not already done so, please try again with the same card or a different card.</span>', TRUE, FALSE, now(), now(), 'Sent to customer if invoice has been failing for 1 day', 'en', NULL)")
    end

    def set_org_failed_payment_date(org, d)
      org.update_attributes(last_failed_payment_date: Time.zone.now.to_date - d.days, last_payment_successful: false, time_zone: 'Eastern Time (US & Canada)')
    end

    it 'owners card fails on paying invoice after 1 day' do
      owner = log_in(create(:user, :paid_owner))
      org = owner.organization
      set_org_failed_payment_date(org, 1)
      Organization.send_failed_payment_reminder

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.last.to.should == [owner.email]
      ActionMailer::Base.deliveries.last.body.should have_content('6 day(s) until your account can no longer use our service')
      ActionMailer::Base.deliveries.last.subject.should have_content('Failed Payment Reminder')
    end

    it 'owners card fails on paying invoice after 2 days' do
      owner = log_in(create(:user, :paid_owner))
      org = owner.organization
      set_org_failed_payment_date(org, 2)
      Organization.send_failed_payment_reminder

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.last.to.should == [owner.email]
      ActionMailer::Base.deliveries.last.body.should have_content('5 day(s) until your account can no longer use our service')
      ActionMailer::Base.deliveries.last.subject.should have_content('Failed Payment Reminder')
    end


    it 'owners card fails on paying invoice after 5 days' do
      owner = log_in(create(:user, :paid_owner))
      org = owner.organization
      set_org_failed_payment_date(org, 5)
      Organization.send_failed_payment_reminder

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.last.to.should == [owner.email]
      ActionMailer::Base.deliveries.last.body.should have_content('2 day(s) until your account can no longer use our service')
      ActionMailer::Base.deliveries.last.subject.should have_content('Failed Payment Reminder')
    end

    it 'owners card fails on paying invoice after 7 days' do
      owner = log_in(create(:user, :paid_owner))
      org = owner.organization
      set_org_failed_payment_date(org, 7)
      org.failed_payment_cancellation

      org.id.should equal(org.id)
      org.stripe_plan_name.should === 'Free'
      org.stripe_plan_id.should === 'Free'
      org.trial_end_date.should < Time.zone.now.to_date

    end

  end

end
