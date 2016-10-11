class AddNoteToCommunications < ActiveRecord::Migration
  def change
    add_column :communications, :note, :string
  end
end
