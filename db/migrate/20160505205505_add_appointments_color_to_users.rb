class AddAppointmentsColorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :appointments_color, :string
  end
end
