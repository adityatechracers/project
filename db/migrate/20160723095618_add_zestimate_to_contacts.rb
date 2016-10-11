class AddZestimateToContacts < ActiveRecord::Migration
  def change
  	add_column :contacts, :zestimate, :integer
  	add_column :contacts, :discard_zestimate, :boolean, default: false
  end
end
