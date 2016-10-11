class AddSubCustomerColumnToQuickBooksExpenseLineItems < ActiveRecord::Migration
  def change
    add_column :quick_books_expense_line_items, :sub_customer_id, :integer, null:false
  end
end
