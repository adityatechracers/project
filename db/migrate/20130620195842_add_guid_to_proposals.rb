class AddGuidToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :guid, :string
  end
end
