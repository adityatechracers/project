class AddSharedToGoogleCalendars < ActiveRecord::Migration
  def change
    add_column :google_calendars, :shared, :boolean, null: false, default: false
  end
end
