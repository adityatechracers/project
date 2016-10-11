class CreateJobScheduleNotifications < ActiveRecord::Migration
  def change
    create_table :job_schedule_notifications do |t|
      t.belongs_to :job_schedule_entry, null:false
      t.timestamps
    end
    add_index :job_schedule_notifications, :job_schedule_entry_id, unique: true
  end
end
