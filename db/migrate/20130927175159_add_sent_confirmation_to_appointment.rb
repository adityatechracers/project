class AddSentConfirmationToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :sent_confirmation, :boolean, :default => true
  end
end
