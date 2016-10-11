class GoogleEvent < ActiveRecord::Base
  belongs_to :user
  belongs_to :google_calendar

  attr_accessible :description, :end_datetime, :event_id,
  :start_datetime, :status, :title, :user_id, :google_calendar_id

  validates :event_id, :uniqueness => {:scope => :google_calendar_id}
  validates :google_calendar_id, presence: true

  scope :not_canceled, where("status <> 'canceled'")
  scope :in_time_range, lambda{|s, e| not_canceled.where("start_datetime BETWEEN ? AND ?", s, e).order("start_datetime ASC") }
  scope :from_shared_calendars, -> { joins(:google_calendar).where(google_calendars: {shared: true}) }
  scope :on_day, lambda {|date| not_canceled.where("date(start_datetime) = ?", date)}


  def to_event
    {
      :id => self.id,
      :userId => self.user_id,
      :allDay => false,
      :title => self.event_title,
      :notes => self.description,
      :start => self.start_datetime,
      :end => self.end_datetime,
      :color => self.user.appointments_color,
      :from_google => true
    }
  end

  def self.find_within_calendar(calendar, event)
    self.where(google_calendar_id: calendar, event_id: event).first_or_initialize
  end

  def event_title
    self.title
  end

  def identical?(other)
    this_event = self.dup
    other_event = other.dup
    this_event.attributes == other_event.attributes
  end

end
