class AddAgreementToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :agreement, :text
  end
end
