class SetExpensesFieldsNotNull < ActiveRecord::Migration
  def up
    change_column :expenses, :amount, :decimal, precision: 9, scale: 2, null: false, default: 0
    change_column :expenses, :job_id, :integer, null: false
  end

  def down
    change_column :expenses, :amount, :decimal, :precision => 9, :scale => 2
    change_column :expenses, :job_id, :integer
  end
end
