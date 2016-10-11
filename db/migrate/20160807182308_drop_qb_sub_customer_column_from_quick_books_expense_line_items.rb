class DropQbSubCustomerColumnFromQuickBooksExpenseLineItems < ActiveRecord::Migration
 def up 
  QuickBooks::ExpenseLineItem.delete_all
  remove_column :quick_books_expense_line_items, :qb_sub_customer_id
 end 
 def down
  add_column :quick_books_expense_line_items, :qb_sub_customer_id, :string 
 end
end
