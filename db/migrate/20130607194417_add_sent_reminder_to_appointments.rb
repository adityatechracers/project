class AddSentReminderToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :sent_reminder, :boolean, :default => false
  end
end
