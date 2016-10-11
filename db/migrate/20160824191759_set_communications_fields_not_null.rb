class SetCommunicationsFieldsNotNull < ActiveRecord::Migration
  def up
    change_column :communications, :details, :text, null: false, default: ""
  end

  def down
    change_column :communications, :details, :text
  end
end
