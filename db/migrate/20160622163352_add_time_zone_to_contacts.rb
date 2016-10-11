class AddTimeZoneToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :time_zone, :string
  end
end
