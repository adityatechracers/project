class SetUserFieldsNotNull < ActiveRecord::Migration
  def up
    change_column :users, :last_name, :string, null: false, default: ""
    change_column :users, :first_name, :string, null: false, default: ""
  end

  def down
    change_column :users, :last_name, :string
    change_column :users, :first_name, :string
  end
end
