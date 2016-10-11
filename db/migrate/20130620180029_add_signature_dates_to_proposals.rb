class AddSignatureDatesToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :customer_sig_datetime, :datetime
    add_column :proposals, :contractor_sig_datetime, :datetime
  end
end
