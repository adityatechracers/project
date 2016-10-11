class AddGoogleCalendarToGoogleEvents < ActiveRecord::Migration
  def change
    add_column :google_events, :google_calendar_id, :integer, references: :google_calendars
    add_index  :google_events, :google_calendar_id
  end
end
