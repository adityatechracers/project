class AddProposalBannerTextToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :proposal_banner_text, :text
  end
end
