class AddAgreementToProposalTemplates < ActiveRecord::Migration
  def change
    add_column :proposal_templates, :agreement, :text
  end
end
