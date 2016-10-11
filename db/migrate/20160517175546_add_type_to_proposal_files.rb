class AddTypeToProposalFiles < ActiveRecord::Migration
  def up
    add_column :proposal_files, :type, :string
  end

  def down
    remove_column :proposal_files, :type
  end
end
