class FixPrecisionForUserPayrate < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.remove :pay_rate
      t.float :pay_rate, :precision => 10, :scale => 2, :default => 0
    end
  end

  def down
    change_table :users do |t|
      t.remove :pay_rate
      t.float :pay_rate
    end
  end
end
