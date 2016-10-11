class AddSigToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :customer_sig_printed_name, :string
    add_column :proposals, :customer_sig, :text
    add_column :proposals, :customer_sig_user_id, :integer
    add_column :proposals, :contractor_sig_printed_name, :string
    add_column :proposals, :contractor_sig, :text
    add_column :proposals, :contractor_sig_user_id, :integer
  end
end
