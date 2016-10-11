class AddAddress2ToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :address2, :string
    add_column :proposals, :country, :string
  end
end
