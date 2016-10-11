class AddDeletedAtToExpenseCategory < ActiveRecord::Migration
  def change
    add_column :expense_categories, :deleted_at, :datetime
  end
end
