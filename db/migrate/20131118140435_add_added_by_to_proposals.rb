class AddAddedByToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :added_by, :integer
  end
end
