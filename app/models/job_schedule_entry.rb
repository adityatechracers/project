# == Schema Information
#
# Table name: job_schedule_entries
#
#  id                :integer          not null, primary key
#  job_id            :integer          not null
#  start_datetime    :datetime         not null
#  end_datetime      :datetime         not null
#  notes             :text
#  is_touch_up       :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  system_generated  :boolean          default(FALSE), not null
#  crew_id           :integer
#  sent_notification :boolean          default(FALSE), not null
#

class JobScheduleEntry < ActiveRecord::Base
  attr_accessible :job_id, :start_datetime, :end_datetime, :notes, :is_touch_up, :crew_id, :make_default_crew, :user_ids, :sent_notification, :should_send_notification
  attr_accessor :make_default_crew

  belongs_to :job
  belongs_to :crew

  has_many :job_schedule_entry_users
  has_many :users, :through => :job_schedule_entry_users

  after_save :save_job
  before_save :update_sent_notification_status
  after_destroy :save_job

  validates_presence_of :job_id, :start_datetime, :end_datetime

  scope :for_crew, ->(crew) { where(crew_id: crew.id) }
  scope :occurring_on_date, ->(date) { where('DATE(start_datetime) <= :date and DATE(end_datetime) >= :date', date: date) }
  scope :sent, -> {where sent_notification:true}
  include JobNotifications 
  include ScheduleEntry

  def self.send_reminders
    # This is intended to be run at most once per day. There's no safeguard to prevent the reminders
    # from being sent multiple times if this was called more than once per day.
    [1, 3, 7].each do |days_from_now|
      where('DATE(start_datetime) = ?', Date.today + days_from_now).each do |schedule_entry|
        ActsAsTenant.with_tenant(schedule_entry.job.organization) do
          JobsMailer.job_scheduled_reminder(schedule_entry.job, schedule_entry, days_from_now).deliver
        end
      end
    end
  end
  
  def color
    if job.overbudget?
      "#CC3333"
    elsif crew.present?
      crew.color
    else
      nil
    end
  end

  def title
    %{ #{job.full_title} (#{job.calculated_hours.to_i}/#{job.budgeted_hours} budgeted hours)
       #{job.contact.condensed_address}
       #{job.contact.phone}}
  end

  def small_title
    %{#{job.contact.name}
      #{job.title}
      #{job.contact.condensed_address}
      #{job.estimated_amount}}
  end

  def to_date_range
    start_datetime.to_date..end_datetime.to_date
  end

  def to_event
    {
      id: id,
      crewId: crew_id,
      color: color,
      allDay: false,
      title: title,
      start: start_datetime.to_s,
      end: end_datetime.to_s,
      touchUp: is_touch_up,
      hasNotes: notes.present?
    }
  end

  private

  def save_job
    job.crew_id = crew_id if make_default_crew == "1"

    #update job.date_of_first_job_schedule_entry which is a date cache for reporting convenience
    if(job.job_schedule_entries.count > 0)
      job.date_of_first_job_schedule_entry = job.job_schedule_entries.order(:start_datetime).first.start_datetime.to_date
    else
      job.date_of_first_job_schedule_entry = nil
    end

    job.save # Trigger state change.
  end

  def update_sent_notification_status
    if self.start_datetime_changed? || self.end_datetime_changed?
      self.sent_notification = false
    end

    return true
  end
end
