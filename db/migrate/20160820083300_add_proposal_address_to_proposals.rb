class AddProposalAddressToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :proposal_address, :string
  end
end
