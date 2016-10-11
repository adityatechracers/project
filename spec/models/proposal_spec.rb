require 'spec_helper'

describe Proposal do
  before(:each) { ActionMailer::Base.deliveries = [] }

  def create_proposals(delta)
    @org1 = create(:organization, :with_owner, time_zone: 'Eastern Time (US & Canada)')
    @job1 = create(:job, :organization_id => @org1.id)

    @org2 = create(:organization, :with_owner, time_zone: 'Eastern Time (US & Canada)')
    @job2 = create(:job, :organization_id => @org2.id)

    Time.use_zone(@org1.time_zone) do
      @proposal1 = create(:proposal, :proposal_state => 'Issued', :job_id => @job1.id, :organization_id => @org1.id)
      @proposal1.update_attribute(:created_at, Time.zone.now.to_date - delta.days)

      @declined1 = create(:proposal, :proposal_state => 'Declined', :job_id => @job1.id, :organization_id => @org1.id)
      @declined1.update_attribute(:created_at, Time.zone.now.to_date - delta.days)

      @too_old1 = create(:proposal, :proposal_state => 'Issued', :job_id => @job1.id, :organization_id => @org1.id)
      @too_old1.update_attribute(:created_at, Time.zone.now.to_date - (delta + 0.1).days)

      @too_new1 = create(:proposal, :proposal_state => 'Issued', :job_id => @job1.id, :organization_id => @org1.id)
      @too_new1.update_attribute(:created_at, Time.zone.now.to_date - (delta - 1).days)
    end
    Time.use_zone(@org2.time_zone) do
      @proposal2 = create(:proposal, :proposal_state => 'Issued', :job_id => @job2.id, :organization_id => @org2.id)
      @proposal2.update_attribute(:created_at, Time.zone.now.to_date - delta.days)

      @declined2 = create(:proposal, :proposal_state => 'Declined', :job_id => @job2.id, :organization_id => @org2.id)
      @declined2.update_attribute(:created_at, Time.zone.now.to_date - delta.days)

      @too_old2 = create(:proposal, :proposal_state => 'Issued', :job_id => @job2.id, :organization_id => @org2.id)
      @too_old2.update_attribute(:created_at, Time.zone.now.to_date - (delta + 0.1).days)

      @too_new2 = create(:proposal, :proposal_state => 'Issued', :job_id => @job2.id, :organization_id => @org2.id)
      @too_new2.update_attribute(:created_at, Time.zone.now.to_date - (delta - 1).days)
    end
  end

  it 'sends 2 day reminder emails to client of issued proposal' do
    create_proposals(2)

    create(:email_template, :name => 'proposal-issued-2-day-reminder', :organization_id => @org1.id)
    create(:email_template, :name => 'proposal-issued-2-day-reminder', :organization_id => @org2.id)

    Proposal.send_issued_2_day_reminders

    ActionMailer::Base.deliveries.count.should == 4
    addresses = ActionMailer::Base.deliveries.map(&:to).flatten
    addresses.should include(@proposal1.job.contact.email)
    addresses.should include(@proposal2.job.contact.email)
  end

  it 'sends 1 week reminder emails to client of issued proposal' do
    create_proposals(7)

    create(:email_template, :name => 'proposal-issued-1-week-reminder', :organization_id => @org1.id)
    create(:email_template, :name => 'proposal-issued-1-week-reminder', :organization_id => @org2.id)

    Proposal.send_issued_1_week_reminders

    ActionMailer::Base.deliveries.count.should == 4
    addresses = ActionMailer::Base.deliveries.map(&:to).flatten
    addresses.should include(@proposal1.job.contact.email)
    addresses.should include(@proposal2.job.contact.email)
  end

  it 'sends 1 month reminder emails to client of issued proposal' do
    create_proposals(30)

    create(:email_template, :name => 'proposal-issued-1-month-reminder', :organization_id => @org1.id)
    create(:email_template, :name => 'proposal-issued-1-month-reminder', :organization_id => @org2.id)

    Proposal.send_issued_1_month_reminders

    ActionMailer::Base.deliveries.count.should == 4
    addresses = ActionMailer::Base.deliveries.map(&:to).flatten
    addresses.should include(@proposal1.job.contact.email)
    addresses.should include(@proposal2.job.contact.email)
  end

  it 'sends 2 month reminder emails to client of issued proposal' do
    create_proposals(60)

    create(:email_template, :name => 'proposal-issued-2-month-reminder', :organization_id => @org1.id)
    create(:email_template, :name => 'proposal-issued-2-month-reminder', :organization_id => @org2.id)

    Proposal.send_issued_2_month_reminders

    ActionMailer::Base.deliveries.count.should == 4
    addresses = ActionMailer::Base.deliveries.map(&:to).flatten
    addresses.should include(@proposal1.job.contact.email)
    addresses.should include(@proposal2.job.contact.email)
  end

  it 'sends 3 month reminder emails to client of issued proposal' do
    create_proposals(90)

    create(:email_template, :name => 'proposal-issued-3-month-reminder', :organization_id => @org1.id)
    create(:email_template, :name => 'proposal-issued-3-month-reminder', :organization_id => @org2.id)

    Proposal.send_issued_3_month_reminders

    ActionMailer::Base.deliveries.count.should == 4
    addresses = ActionMailer::Base.deliveries.map(&:to).flatten
    addresses.should include(@proposal1.job.contact.email)
    addresses.should include(@proposal2.job.contact.email)
  end
end

# == Schema Information
#
# Table name: proposals
#
#  title                       :string(255)
#  job_id                      :integer
#  proposal_template_id        :integer
#  proposal_number             :integer
#  address                     :string(255)
#  city                        :string(255)
#  region                      :string(255)
#  zip                         :string(255)
#  license_number              :string(255)
#  proposal_class              :string(255)
#  speciality                  :string(255)
#  proposal_date               :date
#  sales_person_id             :integer
#  contractor_id               :integer
#  organization_id             :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  address2                    :string(255)
#  country                     :string(255)
#  notes                       :text
#  signed_by                   :integer
#  customer_sig_printed_name   :string(255)
#  customer_sig                :text
#  customer_sig_user_id        :integer
#  contractor_sig_printed_name :string(255)
#  contractor_sig              :text
#  contractor_sig_user_id      :integer
#  proposal_state              :string(255)
#  amount                      :decimal(9, 2)    default(0.0)
#  agreement                   :text
#  customer_sig_datetime       :datetime
#  contractor_sig_datetime     :datetime
#  guid                        :string(255)      not null
#  budgeted_hours              :integer          default(0)
#  id                          :integer          not null, primary key
#  deleted_at                  :datetime
#  added_by                    :integer
#  expected_start_date         :date
#  expected_end_date           :date
#
