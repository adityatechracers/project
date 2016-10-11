class AddTenanciesToModels < ActiveRecord::Migration
  def change
    add_column :appointments, :organization_id, :integer
    add_column :communications, :organization_id, :integer
    add_column :crews, :organization_id, :integer
    add_column :jobs, :organization_id, :integer
  end
end
