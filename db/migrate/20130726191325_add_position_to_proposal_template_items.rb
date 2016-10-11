class AddPositionToProposalTemplateItems < ActiveRecord::Migration
  def change
    add_column :proposal_template_items, :position, :integer
  end
end
