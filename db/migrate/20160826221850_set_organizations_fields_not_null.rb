class SetOrganizationsFieldsNotNull < ActiveRecord::Migration
  def up
    change_column :organizations, :name, :string, null: false, default: ""
    change_column :organizations, :email, :string, null: false, default: ""
  end

  def down
    change_column :organizations, :name, :string
    change_column :organizations, :email, :string
  end
end
