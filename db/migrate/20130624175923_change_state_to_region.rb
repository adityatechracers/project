class ChangeStateToRegion < ActiveRecord::Migration
  def up
    rename_column :contacts, :state, :region
    rename_column :organizations, :state, :region
    rename_column :proposals, :state, :region
    rename_column :users, :state, :region
    add_column :organizations, :country, :string
  end

  def down
    rename_column :contacts, :region, :state
    rename_column :organizations, :region, :state
    rename_column :proposals, :region, :state
    rename_column :users, :region, :state
    remove_column :organizations, :country
  end
end
