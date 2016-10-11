class AddSoftDeletionToProposalTemplateChildren < ActiveRecord::Migration
  def change
    add_column :proposal_template_sections, :deleted_at, :datetime
    add_column :proposal_template_items, :deleted_at, :datetime
  end
end
