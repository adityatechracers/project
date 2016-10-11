class CreateExpenseCategories < ActiveRecord::Migration
  def change
    create_table :expense_categories do |t|
      t.integer :organization_id
      t.string :name

      t.timestamps
    end
  end
end
