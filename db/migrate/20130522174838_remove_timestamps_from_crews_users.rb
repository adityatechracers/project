class RemoveTimestampsFromCrewsUsers < ActiveRecord::Migration
  def up
    remove_column :crews_users, :created_at
    remove_column :crews_users, :updated_at
  end

  def down
  end
end
