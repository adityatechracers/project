class SetChangeOrdersFieldsNotNull < ActiveRecord::Migration
  def up
    change_column :change_orders, :change_description, :text, null: false, default: ""
  end

  def down
    change_column :change_orders, :change_description, :text
  end
end
