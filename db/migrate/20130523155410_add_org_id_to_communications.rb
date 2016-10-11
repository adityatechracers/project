class AddOrgIdToCommunications < ActiveRecord::Migration
  def change
    add_column :communications, :organization_id, :integer
  end
end
