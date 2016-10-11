class AddStuffToProposalTemplates < ActiveRecord::Migration
  def change
    add_column :proposal_templates, :proposal_class, :string
    add_column :proposal_templates, :speciality, :string
  end
end
