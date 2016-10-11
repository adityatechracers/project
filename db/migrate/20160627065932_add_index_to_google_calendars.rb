class AddIndexToGoogleCalendars < ActiveRecord::Migration
  def change
    add_index :google_calendars, :calendar_id
  end
end
