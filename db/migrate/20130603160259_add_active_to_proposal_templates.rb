class AddActiveToProposalTemplates < ActiveRecord::Migration
  def change
    add_column :proposal_templates, :active, :boolean, :default => true
  end
end
