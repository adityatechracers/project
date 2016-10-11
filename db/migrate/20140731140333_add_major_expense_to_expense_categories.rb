class AddMajorExpenseToExpenseCategories < ActiveRecord::Migration
  def change
    add_column :expense_categories, :major_expense, :boolean, null: false, default: false
  end
end
