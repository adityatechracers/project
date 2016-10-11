class SetPaymentFieldsNotNull < ActiveRecord::Migration
  def up
    change_column :payments, :amount, :decimal, precision: 9, scale: 2, null: false, default: 0
    change_column :payments, :job_id, :integer, null: false
  end

  def down
    change_column :payments, :amount, :decimal, :precision => 9, :scale => 2
    change_column :payments, :job_id, :integer
  end
end
