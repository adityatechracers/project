class AddIndexToProposalGuid < ActiveRecord::Migration
  def up
    remove_column :proposals, :id
    execute "ALTER TABLE proposals ADD PRIMARY KEY (guid);"
  end

  def down
    execute "ALTER TABLE proposals REMOVE PRIMARY KEY (guid);"
    add_column :proposals, :id, :primary_key
  end
end
