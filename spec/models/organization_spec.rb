# == Schema Information
#
# Table name: organizations
#
#  id                             :integer          not null, primary key
#  name                           :string(255)
#  guid                           :string(255)
#  premium_override               :boolean
#  stripe_plan_id                 :string(255)
#  stripe_customer_token          :string(255)
#  last_payment_successful        :boolean
#  last_payment_date              :datetime
#  stripe_plan_name               :string(255)
#  name_on_credit_card            :string(255)
#  last_four_digits               :string(255)
#  address                        :string(255)
#  address_2                      :string(255)
#  city                           :string(255)
#  region                         :string(255)
#  zip                            :string(255)
#  email                          :string(255)
#  phone                          :string(255)
#  fax                            :string(255)
#  license_number                 :string(255)
#  logo_file_name                 :string(255)
#  logo_content_type              :string(255)
#  logo_file_size                 :integer
#  logo_updated_at                :datetime
#  timecard_lock_period           :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  active                         :boolean          default(TRUE)
#  trial_start_date               :datetime
#  embed_help_text                :text
#  embed_thank_you                :text
#  time_zone                      :string(255)
#  trial_end_date                 :datetime
#  country                        :string(255)
#  default_signature              :text
#  auto_sign_proposals            :boolean          default(FALSE), not null
#  proposal_style                 :string(255)      default("CorkCRM"), not null
#  uses_crew_commissions          :boolean          default(FALSE), not null
#  website_url                    :string(255)
#  proposal_banner_text           :text
#  proposal_paper_size            :string(255)      default("A4"), not null
#  feedback_portal_text           :text
#  feedback_portal_show_signature :boolean          default(FALSE), not null
#  proposal_options               :text
#  num_allowed_users              :integer          default(1), not null
#  parent_organization_id         :integer
#  user_signatures                :text
#

require 'spec_helper'

describe Organization do
  before(:each) { ActionMailer::Base.deliveries = [] }

  # Creates test organizations given a delta which represents the number of
  # days ago on which the organization's trial was started.
  def create_organizations(delta)
    @too_old = create(:organization, :with_owner, :trial, time_zone: 'Eastern Time (US & Canada)')
    Time.use_zone(@too_old.time_zone) do
      @too_old.update_attribute(:trial_start_date, Time.zone.now.to_date - (delta + 0.1).days)
      @too_old.update_attribute(:trial_end_date, Time.zone.now.to_date - (delta + 0.1).days + 14.days)
    end

    @too_new = create(:organization, :with_owner, :trial, time_zone: 'Eastern Time (US & Canada)')
    Time.use_zone(@too_new.time_zone) do
      @too_new.update_attribute(:trial_start_date, Time.zone.now.to_date - (delta - 1).day)
      @too_new.update_attribute(:trial_end_date, Time.zone.now.to_date - (delta - 1).day + 14.days)
    end

    @paid = create(:organization, :with_owner, :paid, time_zone: 'Eastern Time (US & Canada)')
    Time.use_zone(@paid.time_zone) do
      @paid.update_attribute(:created_at, Time.zone.now.to_date - delta.days)
      @paid.update_attribute(:trial_start_date, Time.zone.now.to_date - delta.days)
      @paid.update_attribute(:trial_end_date, Time.zone.now.to_date - delta.days + 14.days)
    end

    @org1 = create(:organization, :with_owner, :trial, time_zone: 'Eastern Time (US & Canada)')
    Time.use_zone(@org1.time_zone) do
      @org1.update_attribute(:trial_start_date, Time.zone.now.to_date - delta.days)
      @org1.update_attribute(:trial_end_date, Time.zone.now.to_date - delta.days + 14.days)
    end

    @org2 = create(:organization, :with_owner, :trial, time_zone: 'Eastern Time (US & Canada)')
    Time.use_zone(@org2.time_zone) do
      @org2.update_attribute(:trial_start_date, Time.zone.now.to_date - (delta - 0.4).days)
      @org2.update_attribute(:trial_end_date, Time.zone.now.to_date - (delta - 0.4).days + 14.days)
    end

    @org3 = create(:organization, :with_owner, :trial, time_zone: 'Eastern Time (US & Canada)')
    Time.use_zone(@org3.time_zone) do
      @org3.update_attribute(:trial_start_date, Time.zone.now.to_date - (delta - 0.6).days)
      @org3.update_attribute(:trial_end_date, Time.zone.now.to_date - (delta - 0.6).days + 14.days)
    end
  end

  it 'sends 2 day follow up emails to trial accounts' do
    create(:email_template, :name => 'trial-2-day-follow-up')

    create_organizations(2)

    Organization.send_trial_2_day_follow_ups

    ActionMailer::Base.deliveries.count.should == 9
    addresses = ActionMailer::Base.deliveries.map(&:to).flatten
    addresses.should include(@org1.owner.email)
    addresses.should include(@org2.owner.email)
    addresses.should include(@org3.owner.email)
  end

  it 'sends 7 day follow up emails to trial accounts' do
    create(:email_template, :name => 'trial-7-day-follow-up')

    create_organizations(7)

    Organization.send_trial_7_day_follow_ups

    ActionMailer::Base.deliveries.count.should == 9
    addresses = ActionMailer::Base.deliveries.map(&:to).flatten
    addresses.should include(@org1.owner.email)
    addresses.should include(@org2.owner.email)
    addresses.should include(@org3.owner.email)
  end

  it 'sends 10 day follow up emails to trial accounts' do
    create(:email_template, :name => 'trial-10-day-follow-up')

    create_organizations(10)

    Organization.send_trial_10_day_follow_ups

    ActionMailer::Base.deliveries.count.should == 9
    addresses = ActionMailer::Base.deliveries.map(&:to).flatten
    addresses.should include(@org1.owner.email)
    addresses.should include(@org2.owner.email)
    addresses.should include(@org3.owner.email)
  end

  it 'sends 1 month follow up emails to active (i.e. paid) accounts' do
    create(:email_template, :name => 'active-1-month-follow-up')

    create_organizations(30)

    Organization.send_active_1_month_follow_ups

    ActionMailer::Base.deliveries.count.should == 7 # First 6 go to Michael Henry
    addresses = ActionMailer::Base.deliveries.map(&:to).flatten
    addresses.should include(@paid.owner.email)
  end

  it 'sends expiration notices to expired trial accounts' do
    create(:email_template, :name => 'trial-expiration-notice')

    create_organizations(14) # 14 trial days

    Organization.send_trial_expiration_notices

    ActionMailer::Base.deliveries.count.should == 9
    addresses = ActionMailer::Base.deliveries.map(&:to).flatten
    addresses.should include(@org1.owner.email)
    addresses.should include(@org2.owner.email)
    addresses.should include(@org3.owner.email)
  end

  it 'sends 7 day follow up emails to expired trial accounts' do
    create(:email_template, :name => 'expired-7-day-follow-up')

    create_organizations(21) # 21 days ago (14 trial days + 7 expired days )

    Organization.send_expired_7_day_follow_ups

    ActionMailer::Base.deliveries.count.should == 9
    addresses = ActionMailer::Base.deliveries.map(&:to).flatten
    addresses.should include(@org1.owner.email)
    addresses.should include(@org2.owner.email)
    addresses.should include(@org3.owner.email)
  end

  it 'sends 1 month follow up emails to expired trial accounts' do
    create(:email_template, :name => 'expired-1-month-follow-up')

    create_organizations(44) # 44 days ago (14 trial days + 30 expired days )

    Organization.send_expired_1_month_follow_ups

    ActionMailer::Base.deliveries.count.should == 9 # First six go to Michael Henry
    addresses = ActionMailer::Base.deliveries.map(&:to).flatten
    addresses.should include(@org1.owner.email)
    addresses.should include(@org2.owner.email)
    addresses.should include(@org3.owner.email)
  end
end
