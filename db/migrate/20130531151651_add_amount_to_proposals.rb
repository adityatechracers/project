class AddAmountToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :amount, :float
  end
end
