class AddSignedByToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :signed_by, :integer
  end
end
