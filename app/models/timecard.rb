class Timecard < ActiveRecord::Base
  attr_accessible :amount, :duration, :end_datetime, :job_id, :notes, :organization_id, :pay_rate, :start_datetime, :state, :user_id

  scope :from_time_range, lambda{|s, e| not_deleted.where('start_datetime BETWEEN ? AND ?', s, e) }
  scope :entered, not_deleted.where(:state => 'Entered')
  scope :approved, not_deleted.where(:state => 'Approved')
  scope :paid, not_deleted.where(:state => 'Paid')
  scope :locked_timecards, lambda { not_deleted.where('start_datetime < ? OR end_datetime < ?',
                                    Time.zone.now.beginning_of_week, Time.zone.now.beginning_of_week) }
  # Try to avoid naming things `locked`: https://github.com/rails/rails/issues/7421

  belongs_to :job
  belongs_to :user

  acts_as_tenant :organization

  before_save :calculate_amount
  validates_presence_of :user_id, :job_id, :start_datetime, :end_datetime
  validate :valid_dates?

  STATES = ["Entered","Approved","Paid"]

  def to_event
    title = if self.job.nil? then self.user.name
            else
              [
                  self.user.name,
                  ((self.job.crew.present?) ? self.job.crew.name : "No crew"),
                  "",
                  self.job.full_title,
                  self.job.contact.name,
                  self.job.contact.condensed_address,
                  "",
                  self.notes
              ].join("\n")
            end
    {
      id: id,
      jobId: job_id,
      userId: user_id,
      title: title,
      notes: notes,
      start: start_datetime.to_s,
      end: end_datetime.to_s,
      allDay: false,
      payRate: pay_rate,
      amount: amount,
      duration: duration,
      can_be_past: true
    }
  end

  def locked?
    self.organization.timecard_locks_enabled? &&
    self.start_datetime < Time.zone.now.beginning_of_week &&
    self.end_datetime < Time.zone.now.beginning_of_week
  end

  def self.get_total_expense job_id
    expense = 0
    Timecard.where(job_id: job_id).where(deleted_at: nil).each do |timecard|
      expense = expense + (timecard.amount)
    end
    expense
  end
  
  private

  # We try to lock the pay rate so that changes to the user's
  # rate are not applied retroactively when editing past timecards.
  #
  # In some cases, the lock needs to be overridden---e.g., if the
  # user was changed.
  def applicable_pay_rate
    current_user_pay_rate = user.pay_rate || 0

    if user_id_was.present? && user_id != user_id_was
      current_user_pay_rate
    else
      pay_rate || current_user_pay_rate
    end
  end

  def calculate_amount
    self.state ||= "Entered"

    # Locked in place after initial save
    self.pay_rate = applicable_pay_rate

    # These should be calculated every time, as the dates may have changed.
    self.duration = (end_datetime - start_datetime) / 1.hour
    self.amount = pay_rate * duration
  end

  def valid_dates?
    return if self.start_datetime.blank? || self.end_datetime.blank?
    if self.start_datetime > self.end_datetime
      errors.add(:start_datetime, "Must be before end time")
      errors.add(:end_datetime, "Must be after start time")
    end

    errors.add(:start_datetime, "can't be in the future") if self.start_datetime > Time.zone.now
    errors.add(:end_datetime, "can't be in the future") if self.end_datetime > Time.zone.now

    return true unless self.organization.timecard_locks_enabled?
    week_start = Time.zone.now.beginning_of_week
    [:start_datetime, :end_datetime].each do |attr|
      errors.add(attr, "Must be after #{I18n.l week_start}") unless send(attr) > week_start
    end
  end
end

# == Schema Information
#
# Table name: timecards
#
#  id              :integer          not null, primary key
#  job_id          :integer
#  organization_id :integer
#  user_id         :integer
#  start_datetime  :datetime
#  end_datetime    :datetime
#  notes           :text
#  state           :string(255)
#  amount          :decimal(9, 2)
#  duration        :float
#  pay_rate        :decimal(9, 2)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#
