class AddIndexesToGoogleEvents < ActiveRecord::Migration
  def change
    add_index :google_events, [:calendar, :event_id]
  end
end
