class GoogleCalendar < ActiveRecord::Base

  belongs_to :user
  has_many :google_events, dependent: :delete_all

  attr_accessible :access_role, :calendar_id, :primary, :time_zone, :title, :user_id

  validates :user_id, presence: true

  after_create :set_sharing_status

  scope :shared, where(shared: true)
  scope :shareable, where("access_role = 'owner' OR access_role = 'writer'")

  def identical?(other)
    this_calendar = self.dup
    other_calendar = other.dup
    this_calendar.attributes == other_calendar.attributes
  end

  def set_sharing_status
    self.update_attribute(:shared, true) if self.primary?
  end

  def can_be_shared?
    self.access_role == "owner" || self.access_role == "writer"
  end

end
