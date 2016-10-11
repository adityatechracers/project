class AddIndexToGoogleEvents < ActiveRecord::Migration
  def change
    add_index :google_events, :event_id
  end
end
