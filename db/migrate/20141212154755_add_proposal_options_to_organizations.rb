class AddProposalOptionsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :proposal_options, :text
  end
end
