class AddEstimatedAmountToJobs < ActiveRecord::Migration
  def up
    change_table :jobs do |t|
      t.remove :amount
      t.decimal :estimated_amount, :default => 0, :precision => 9, :scale => 2
      t.remove :budgeted_hours
      t.integer :budgeted_hours, :default => 0
    end
    change_table :proposals do |t|
      t.remove :amount
      t.decimal :amount, :default => 0, :precision => 9, :scale => 2
    end
    change_table :users do |t|
      t.remove :pay_rate
      t.decimal :pay_rate, :default => 0, :precision => 9, :scale => 2
    end
  end
  def down
    change_table :jobs do |t|
      t.float :amount
      t.remove :estimated_amount
      t.remove :budgeted_hours
    end
    change_table :proposals do |t|
      t.remove :amount
      t.float :amount
    end
    change_table :users do |t|
      t.remove :pay_rate
      t.float :pay_rate
    end
  end
end
