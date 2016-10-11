class AddDepositAmountToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :deposit_amount, :decimal, precision: 5, scale: 2, default:0
  end
end
