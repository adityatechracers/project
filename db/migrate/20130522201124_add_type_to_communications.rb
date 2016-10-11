class AddTypeToCommunications < ActiveRecord::Migration
  def change
    add_column :communications, :type, :string
  end
end
