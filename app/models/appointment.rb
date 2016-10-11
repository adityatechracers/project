class Appointment < ActiveRecord::Base
  attr_accessible :email_before_appointment, :end_datetime, :job_id, :notes, :start_datetime, :user_id

  scope :estimates, not_deleted.where("job_id IS NOT NULL")
  scope :available, not_deleted.where("job_id IS NULL")
  scope :with_owner, not_deleted.joins(:user).where("users.role = ?","Owner")
  scope :in_time_range, lambda{|s, e| not_deleted.where("start_datetime BETWEEN ? AND ?", s, e).order("start_datetime ASC") }
  scope :updated_start_date, lambda{|s| not_deleted.where("start_datetime > ?", s).order("start_datetime ASC") }
  scope :today, lambda { in_time_range(Time.zone.now.beginning_of_day, Time.zone.now.end_of_day) }
  scope :current, lambda { not_deleted.where("? BETWEEN start_datetime AND end_datetime",Time.zone.now).order("start_datetime ASC") }
  scope :on_day, lambda {|date| not_deleted.where("date(start_datetime) = ?", date)}

  belongs_to :job
  belongs_to :user
  belongs_to :organization

  acts_as_tenant :organization

  before_save :update_confirmation_status

  validates :start_datetime, :end_datetime, presence: true
  validate :datetimes_are_valid

  def self.send_reminders
    Organization.all.each do |org|
      ActsAsTenant.with_tenant(org) do
        Time.use_zone(org.time_zone) do
          not_deleted
          .where(:email_before_appointment => true)
          .where('job_id IS NOT NULL')
          .where(:sent_reminder => false)
          .where('start_datetime > ? AND start_datetime < ?', Time.zone.now, Time.zone.now + 48.hours)
          .each do |a|
            AppointmentsMailer.reminder(a).deliver
            a.update_column(:sent_reminder, true)
          end
        end
      end
    end
  end

  def self.send_confirmations
    Organization.all.each do |org|
      ActsAsTenant.with_tenant(org) do
        Time.use_zone(org.time_zone) do
          not_deleted
          .where(:sent_confirmation => false)
          .each do |a|
            AppointmentsMailer.confirmation(a).deliver unless a.job.nil?
            a.update_column(:sent_confirmation, true)
          end
        end
      end
    end
  end

  def to_event
    labelday = if self.start_datetime.to_date.today? then "Today" else if self.start_datetime.to_date == Date.tomorrow then "Tomorrow" else "%A, %B %e"+(self.start_datetime.year!=Time.zone.now.year ? ", %Y":"") end end
    {
      :id => self.id,
      :jobId => self.job_id,
      :userId => self.user_id,
      :allDay => false,
      :title => self.title,
      :notes => self.notes,
      :emailBefore => self.email_before_appointment,
      :start => self.start_datetime.to_s,
      :end => self.end_datetime.to_s,
      :start_text => self.start_datetime.strftime("#{labelday} at %l:%M%p"),
      :color => if self.job.present? then self.user.appointments_color end
    }
  end

  def title
    if self.job.nil?
      "Appointment availability for #{self.user.name}"
    else
      "#{self.job.contact.phone}\n#{self.job.contact.condensed_address}\n#{self.job.contact.name}\n#{self.user.name}"
    end
  end

  def cal_title
    if self.job.nil?
      "Appointment availability for #{self.user.name}"
    else
      "#{self.job.contact.phone} | \n#{self.job.contact.condensed_address}\n#{self.job.contact.name}\n#{self.user.name}"
    end
  end

  def to_embedded_event
    output = self.to_event
    output[:title] = "Available appointment slot"
    output
  end

  def is_available?
    self.job.nil?
  end

  def past_communications
    communications = nil
    if self.job.present?
      communications = self.job.communications.past if self.job.communications.any?
    end
    communications
  end

  def job_notes
    last_notes = ""
    unless self.past_communications.nil?
      last_notes += "Last notes: \n"
      self.past_communications.includes(:user).take(5).each do |c|
        last_notes += c.datetime.strftime("%B #{c.datetime.day.ordinalize}, %Y at %l:%M%P") +
        " - " + c.user.name + " - " + c.details + "\n"
      end
    end
    last_notes
  end

  private

  def datetimes_are_valid
    errors.add(:start_datetime, 'must be a valid datetime') if ((DateTime.parse(start_datetime.to_s) rescue ArgumentError) == ArgumentError)
    errors.add(:end_datetime, 'must be a valid datetime') if ((DateTime.parse(end_datetime.to_s) rescue ArgumentError) == ArgumentError)
    if self.start_datetime.present? && self.end_datetime.present?
      if self.start_datetime > self.end_datetime
        errors.add(:start_datetime, "Must be before end time")
        errors.add(:end_datetime, "Must be after start time")
      end
    end
  end

  def update_confirmation_status
    # We don't send confirmations immediately because dragging/dropping would cause a number
    # of confirmations to be sent.
    self.sent_confirmation = false
    true
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
