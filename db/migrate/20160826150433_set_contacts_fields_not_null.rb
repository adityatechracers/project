class SetContactsFieldsNotNull < ActiveRecord::Migration
  def up
    change_column :contacts, :first_name, :string, null: false, default: ""
    change_column :contacts, :last_name, :string, null: false, default: ""
    change_column :contacts, :email, :string, null: false, default: ""
    change_column :contacts, :phone, :string, null: false, default: ""
    change_column :contacts, :address, :string, null: false, default: ""
    change_column :contacts, :zip, :string, null: false, default: ""
    change_column :contacts, :city, :string, null: false, default: ""
  end

  def down
    change_column :contacts, :first_name, :string
    change_column :contacts, :last_name, :string
    change_column :contacts, :email, :string
    change_column :contacts, :phone, :string
    change_column :contacts, :address, :string
    change_column :contacts, :zip, :string
    change_column :contacts, :city, :string
  end
end
