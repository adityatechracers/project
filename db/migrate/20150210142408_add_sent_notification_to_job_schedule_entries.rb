class AddSentNotificationToJobScheduleEntries < ActiveRecord::Migration
  def up
    add_column :job_schedule_entries, :sent_notification, :boolean, default: false, null: false

    # The default is "false" for new entries, but we don't want to send notifications for existing entries.
    JobScheduleEntry.update_all(sent_notification: true)
  end

  def down
    remove_column :job_schedule_entries, :sent_notification
  end
end
