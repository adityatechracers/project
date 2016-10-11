class AddIdToProposal < ActiveRecord::Migration
  def up
    execute "ALTER TABLE proposals DROP CONSTRAINT proposals_pkey;"
    add_column :proposals, :id, :primary_key
  end

  def down
    execute "ALTER TABLE proposals DROP CONSTRAINT proposals_pkey;"
    remove_column :proposals, :id
    execute "ALTER TABLE proposals ADD PRIMARY KEY (guid);"
  end
end
