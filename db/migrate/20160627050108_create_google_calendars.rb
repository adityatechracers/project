class CreateGoogleCalendars < ActiveRecord::Migration
  def change
    create_table :google_calendars do |t|
      t.string :calendar_id
      t.string :title
      t.string :time_zone
      t.string :access_role
      t.boolean :primary
      t.references :user

      t.timestamps
    end
    add_index :google_calendars, :user_id
  end
end
