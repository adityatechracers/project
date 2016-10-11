class RemoveOrganizationIdFromCommunications < ActiveRecord::Migration
  def up
    change_table :communications do |t|
      t.remove :organization_id
    end
  end

  def down
    change_table :communications do |t|
      t.integer :organization_id
    end
  end
end
