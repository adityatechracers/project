class AddShouldSentNotifToJobSchedEntry < ActiveRecord::Migration
  def change
    add_column :job_schedule_entries, :should_send_notification, :boolean, :default => false
  end
end
