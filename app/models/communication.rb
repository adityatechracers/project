class Communication < ActiveRecord::Base
  attr_accessible :action, :details, :job_id, :outcome, :user_id, :datetime, :datetime_exact, :next_step, :type, :organization_id, :note

  belongs_to :job, :inverse_of => :communications
  has_one :contact, :through => :job
  belongs_to :user
  belongs_to :organization

  acts_as_tenant :organization

  scope :future, lambda { not_deleted.where('communications.datetime >= ?', Time.zone.now.to_datetime).order("datetime ASC") }
  scope :past, lambda { not_deleted.where('communications.datetime < ?', Time.zone.now.to_datetime).order("datetime DESC") }
  scope :from_time_range, lambda { |s,e| not_deleted.where('communications.datetime BETWEEN ? AND ?', s, e).order('datetime ASC') }
  scope :planned, not_deleted.where(:type => 'PlannedCommunication').order('datetime ASC')
  scope :records, not_deleted.where(:type => 'CommunicationRecord').order('datetime DESC')
  scope :missed, lambda { not_deleted.where("type = ? AND datetime < ?", "PlannedCommunication", Time.zone.now.to_datetime).order("datetime ASC") }
  scope :today, lambda { not_deleted.where("datetime BETWEEN ? AND ?",Time.zone.now.beginning_of_day,Time.zone.now.end_of_day).order("datetime ASC") }
  scope :planned_for_today, lambda { not_deleted.planned.where("datetime BETWEEN ? AND ?",Time.zone.now.beginning_of_day,Time.zone.now.end_of_day).order("datetime ASC") }
  scope :current, lambda { not_deleted.where("datetime BETWEEN ? AND ?",Time.zone.now,Time.zone.now + 1.hour).order("datetime ASC") }

  OUTCOMES = ["Answered", "No Answer", "Left Message"]
  ACTIONS = ["Call", "Email"]
  NEXT_STEPS = ["dead_lead", "call_back_on", "call_back_around", "schedule_appointment", "schedule_job"]

  validates_presence_of :job
  validates_presence_of :action
  validates_presence_of :details
  validate :datetime_is_valid

  def next
    Communication.not_deleted.where("communications.datetime > ? AND job_id = ?", self.datetime,self.job_id).order("communications.datetime ASC").limit(1).first
  end

  def action_icon
    case self.action
      when "Call" then icon, href = "phone", "tel:"+self.job.contact.phone
      when "Email" then icon, href = "mail-3", "mailto:"+self.job.contact.email
      else icon, href = "question", "#"
    end
    "<a href='#{href}'><i class='icon-#{icon}'></i></a>"
  end

  def datetime_distance
    if self.datetime > Time.zone.now
      distance_of_time_in_words_to_now(self.datetime)+" from now"
    else
      time_ago_in_words(self.datetime)+" ago"
    end
  end

  def summary
    user = self.user.blank? ? "Somebody" : self.user.first_name
    action = self.action.blank? ? "did something" : "#{self.action.downcase}ed"
    "#{user} #{action} #{self.datetime_distance}"
  end

  def missed?
    self.planned? and self.datetime < Time.zone.now
  end

  def planned?
    self.type == "PlannedCommunication"
  end

  def record?
    self.type == "CommunicationRecord"
  end

  def next_step_indicator
    o = ""
    unless self.next.nil?
      o += "<span style='white-space:nowrap;display:block;'>#{self.next_step.gsub('_on','').humanize}</span>" unless self.next_step.blank?
      o += self.next.when_indicator unless self.next.datetime.blank?
    end
    o
  end

  def to_event
    {
      :id => self.id,
      :allDay => false,
      :title => "#{self.action} with #{self.job.contact.name}",
      :start => self.datetime,
      :color => "orange"
    }
  end

  private
  def datetime_is_valid
    errors.add(:datetime, 'must be a valid datetime') if ((DateTime.parse(datetime.to_s) rescue ArgumentError) == ArgumentError)
  end
end

# == Schema Information
#
# Table name: communications
#
#  id              :integer          not null, primary key
#  job_id          :integer
#  user_id         :integer
#  details         :text
#  outcome         :string(255)
#  action          :string(255)
#  datetime        :datetime
#  datetime_exact  :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  next_step       :string(255)
#  type            :string(255)
#  organization_id :integer
#  note            :string(255)
#  deleted_at      :datetime
#
