class AddStuffToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_name, :string
    add_column :users, :first_name, :string
    add_column :users, :phone, :string
    add_column :users, :address, :string
    add_column :users, :address2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zip, :string
    add_column :users, :pay_rate, :float
    add_column :users, :active, :boolean
    add_column :users, :can_view_leads, :boolean
    add_column :users, :can_manage_leads, :boolean
    add_column :users, :can_view_appointments, :boolean
    add_column :users, :can_manage_appointments, :boolean
    add_column :users, :can_view_all_jobs, :boolean
    add_column :users, :can_view_own_jobs, :boolean
    add_column :users, :can_manage_jobs, :boolean
    add_column :users, :can_view_all_proposals, :boolean
    add_column :users, :can_view_assigned_proposals, :boolean
    add_column :users, :can_manage_proposals, :boolean
    add_column :users, :can_be_assigned_appointments, :boolean
    add_column :users, :can_be_assigned_jobs, :boolean
  end
end
