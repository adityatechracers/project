class SetAppointmentsDatetimesNotNull < ActiveRecord::Migration
  def up
    change_column :appointments, :start_datetime, :datetime, null: false
  end

  def down
    change_column :appointments, :start_datetime, :datetime
  end
end
