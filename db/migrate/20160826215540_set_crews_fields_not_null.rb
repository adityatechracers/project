class SetCrewsFieldsNotNull < ActiveRecord::Migration
  def up
    change_column :crews, :name, :string, null: false, default: ""
  end

  def down
    change_column :crews, :name, :string
  end
end
