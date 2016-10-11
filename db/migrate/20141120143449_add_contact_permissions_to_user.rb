class AddContactPermissionsToUser < ActiveRecord::Migration
  def up
    add_column :users, :can_view_all_contacts, :boolean, after: :can_be_assigned_jobs, default: false
    add_column :users, :can_manage_all_contacts, :boolean, after: :can_view_all_contacts, default: false

    # Initially, all existing users can view contacts and those that can manage leads
    # can manage contacts.
    User.update_all(can_view_all_contacts: true)
    User.update_all('can_manage_all_contacts = can_manage_leads')
  end

  def down
    remove_column :users, :can_view_contacts
    remove_column :users, :can_manage_contacts
  end
end
