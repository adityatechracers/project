class AddNotesToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :notes, :text
  end
end
