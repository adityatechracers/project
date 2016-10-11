class CreateJobScheduleEntryUsers < ActiveRecord::Migration
  def change
    create_table :job_schedule_entry_users do |t|
      t.integer :user_id
      t.integer :job_schedule_entry_id

      t.timestamps
    end
    add_index :job_schedule_entry_users, :user_id
    add_index :job_schedule_entry_users, :job_schedule_entry_id
  end
end
