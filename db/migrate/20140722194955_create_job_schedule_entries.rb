class CreateJobScheduleEntries < ActiveRecord::Migration
  def change
    create_table :job_schedule_entries do |t|
      t.integer :job_id, null: false
      t.datetime :start_datetime, null: false
      t.datetime :end_datetime, null: false
      t.text :notes
      t.boolean :is_touch_up, null: false, default: false

      t.timestamps
    end
  end
end
