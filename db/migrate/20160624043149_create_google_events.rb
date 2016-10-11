class CreateGoogleEvents < ActiveRecord::Migration
  def change
    create_table :google_events do |t|
      t.text :event_id
      t.string :title
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.string :status
      t.text :description
      t.string :calendar
      t.references :user

      t.timestamps
    end
    add_index :google_events, :user_id
  end
end
