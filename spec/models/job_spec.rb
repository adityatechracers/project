# == Schema Information
#
# Table name: jobs
#
#  id                               :integer          not null, primary key
#  title                            :string(255)
#  lead_source_id                   :integer
#  contact_id                       :integer
#  details                          :text
#  probability                      :integer
#  state                            :string(255)
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  start_date                       :datetime
#  end_date                         :datetime
#  email_customer                   :boolean          default(FALSE)
#  crew_id                          :integer
#  organization_id                  :integer
#  estimated_amount                 :decimal(9, 2)    default(0.0)
#  state_change_date                :datetime
#  deleted_at                       :datetime
#  added_by                         :integer
#  crew_wage_rate                   :decimal(9, 2)
#  crew_expense_id                  :integer
#  guid                             :string(255)
#  expected_start_date              :date
#  expected_end_date                :date
#  date_of_first_job_schedule_entry :date
#

require 'spec_helper'

describe Job do
  before(:each) { ActionMailer::Base.deliveries = [] }

  def create_job(delta, state = :lead)
    @org = create(:organization, :with_owner, :paid)
    @job = create(:job, state, :organization_id => @org.id)
    @job.update_attribute(:created_at, Time.zone.now.to_date - (delta).days)
  end

  it 'sends 2 day follow up to leads without scheduled appointments' do
    create_job(2)
    create(:email_template, :name => 'appointment-2-day-follow-up', :organization_id => @org.id)

    Job.send_appointment_2_day_follow_ups

    ActionMailer::Base.deliveries.count.should == 2 # One goes to Michael Henry
    ActionMailer::Base.deliveries.last.to.should  == [@job.contact.email]
  end

  it 'sends 7 day follow up to leads without scheduled appointments' do
    create_job(7)
    create(:email_template, :name => 'appointment-7-day-follow-up', :organization_id => @org.id)

    Job.send_appointment_7_day_follow_ups

    ActionMailer::Base.deliveries.count.should == 2 # One goes to Michael Henry
    ActionMailer::Base.deliveries.last.to.should  == [@job.contact.email]
  end

  it 'sends 1 month follow up leads without scheduled appointments' do
    create_job(1.month / 1.day, :completed)
    @job.update_attribute(:state_change_date, Time.zone.now.to_date - 1.month)

    create(:email_template, :name => 'job-complete-1-month-follow-up', :organization_id => @org.id)

    Job.send_job_complete_1_month_follow_ups

    ActionMailer::Base.deliveries.count.should == 2 # One goes to Michael Henry
    ActionMailer::Base.deliveries.last.to.should  == [@job.contact.email]
  end
end
