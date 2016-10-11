require 'spec_helper'

describe Appointment do
  before(:each) { ActionMailer::Base.deliveries = [] }

  it 'sends reminders (once) to filled appointments 48 hours beforehand' do
    org1 = create(:organization, :with_owner, time_zone: 'Eastern Time (US & Canada)')
    org2 = create(:organization, :with_owner, time_zone: 'Eastern Time (US & Canada)')

    create :email_template, :name => 'appointment-reminder', :subject => 'Org 1', :organization_id => org1.id
    create :email_template, :name => 'appointment-reminder', :subject => 'Org 2', :organization_id => org2.id

    app_to_remind_1 = app_to_remind_2 = nil

    # Org should't matter in this context, but we'll make sure it sends reminders for both
    Time.use_zone(org1.time_zone) do
      app_without_job  = create :appointment, :organization_id => org1.id
      app_already_sent = create :appointment, :with_job, :organization_id => org1.id, :sent_reminder => true
      app_past         = create :appointment, :with_job, :organization_id => org1.id, :start_datetime => Time.zone.now - 1.days
      app_to_remind_2  = create :appointment, :with_job, :organization_id => org1.id, :start_datetime => Time.zone.now + 4.hours
    end
    Time.use_zone(org2.time_zone) do
      app_no_remind    = create :appointment, :with_job, :organization_id => org2.id, :email_before_appointment => false
      app_future       = create :appointment, :with_job, :organization_id => org2.id, :start_datetime => Time.zone.now + 10.days
      app_to_remind_1  = create :appointment, :with_job, :organization_id => org2.id, :start_datetime => Time.zone.now + 47.hours
    end

    Appointment.send_reminders

    ActionMailer::Base.deliveries.count.should == 4
    subjects = ActionMailer::Base.deliveries.map(&:subject).flatten
    subjects.should include('Org 1')
    subjects.should include('Org 2')
    Appointment.find(app_to_remind_1.id).sent_reminder.should == true
    Appointment.find(app_to_remind_2.id).sent_reminder.should == true

    # Try it again, should be idempotent
    Appointment.send_reminders
    ActionMailer::Base.deliveries.count.should == 4
  end

  it "takes each organization's TZ into account" do
    org1 = create(:user, :owner).organization
    org1.update_attribute(:time_zone, 'Tokyo')
    org2 = create(:user, :owner).organization
    org2.update_attribute(:time_zone, 'Eastern Time (US & Canada)')

    create :email_template, :name => 'appointment-reminder', :subject => 'Org 1', :organization_id => org1.id
    create :email_template, :name => 'appointment-reminder', :subject => 'Org 2', :organization_id => org2.id

    Time.use_zone(org1.time_zone) do
      app1  = create :appointment, :with_job, :organization_id => org1.id, :start_datetime => Time.zone.now + 47.hours
    end
    Time.use_zone(org2.time_zone) do
      app2  = create :appointment, :with_job, :organization_id => org2.id, :start_datetime => Time.zone.now + 47.hours
    end

    Appointment.send_reminders
    ActionMailer::Base.deliveries.count.should == 4
  end

  it "sends confirmations to both parties of unconfirmed appointments" do
    org1 = create(:user, :owner).organization
    org2 = create(:user, :owner).organization

    create :email_template, :name => 'appointment-confirmation', :subject => 'Confirmation 1', :organization_id => org1.id
    create :email_template, :name => 'appointment-confirmation', :subject => 'Confirmation 2', :organization_id => org2.id

    to_confirm_1 = create :appointment, :with_job, :organization_id => org1.id, :sent_confirmation => false
    to_confirm_2 = create :appointment, :with_job, :organization_id => org2.id, :sent_confirmation => false
    no_job = create :appointment, :organization_id => org1.id, :sent_confirmation => false
    already_confirmed = create :appointment, :organization_id => org1.id, :sent_confirmation => true

    Appointment.send_confirmations
    ActionMailer::Base.deliveries.count.should == 4
    subjects = ActionMailer::Base.deliveries.map(&:subject).flatten
    subjects.should include('Confirmation 1')
    subjects.should include('Confirmation 2')
  end
end

# == Schema Information
#
# Table name: appointments
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  job_id                   :integer
#  start_datetime           :datetime
#  end_datetime             :datetime
#  notes                    :text
#  email_before_appointment :boolean
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  organization_id          :integer
#  sent_reminder            :boolean          default(FALSE)
#  sent_confirmation        :boolean          default(TRUE)
#  deleted_at               :datetime
#
