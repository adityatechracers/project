class AddExpenseCategoryIdToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :expense_category_id, :integer
  end
end
