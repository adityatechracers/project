class AddTypeToProposalTemplates < ActiveRecord::Migration
  def up
    add_column :proposal_templates, :type, :string
  end

  def down
    remove_column :proposal_templates, :type
  end
end
