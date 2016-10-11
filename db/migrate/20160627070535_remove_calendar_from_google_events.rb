class RemoveCalendarFromGoogleEvents < ActiveRecord::Migration
  def up
    remove_index :google_events, column: [:calendar, :event_id]
    remove_column :google_events, :calendar
  end

  def down
    add_column :google_events, :calendar, :string
    add_index :google_events, [:calendar, :event_id]
  end
end