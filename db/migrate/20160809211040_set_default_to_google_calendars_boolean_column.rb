class SetDefaultToGoogleCalendarsBooleanColumn < ActiveRecord::Migration
  def up
    change_column :google_calendars, :primary, :boolean, null: false, default: false
  end

  def down
    change_column :google_calendars, :primary, :boolean
  end
end
