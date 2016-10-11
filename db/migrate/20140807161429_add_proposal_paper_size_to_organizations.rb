class AddProposalPaperSizeToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :proposal_paper_size, :string, default: 'A4', null: false
  end
end
