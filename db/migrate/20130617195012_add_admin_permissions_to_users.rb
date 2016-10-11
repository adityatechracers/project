class AddAdminPermissionsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin_can_view_failing_credit_cards, :boolean, :default => false
    add_column :users, :admin_can_view_billing_history, :boolean, :default => false
    add_column :users, :admin_can_manage_accounts, :boolean, :default => false
    add_column :users, :admin_can_manage_trials, :boolean, :default => false
    add_column :users, :admin_can_manage_cms, :boolean, :default => false
    add_column :users, :admin_can_become_user, :boolean, :default => false
    add_column :users, :admin_receives_notifications, :boolean, :default => false
    add_column :users, :super, :boolean, :default => false
  end
end
