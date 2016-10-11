class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.integer :job_id
      t.integer :organization_id
      t.decimal :amount, :precision => 9, :scale => 2
      t.text :description
      t.date :date_of_expense

      t.timestamps
    end
  end
end
