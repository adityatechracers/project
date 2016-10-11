class SetDefaultToUsersConnectedToGoogle < ActiveRecord::Migration
  def up
    change_column :users, :connected_to_google, :boolean, null: false, default: false
  end

  def down
    change_column :users, :connected_to_google, :boolean
  end
end
