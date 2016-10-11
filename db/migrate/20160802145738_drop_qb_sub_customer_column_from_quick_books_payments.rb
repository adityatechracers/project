class DropQbSubCustomerColumnFromQuickBooksPayments < ActiveRecord::Migration
 def up 
  QuickBooks::SubCustomer.delete_all
  remove_column :quick_books_payments, :qb_sub_customer_id
 end 
 def down
  add_column :quick_books_payments, :qb_sub_customer_id, :string 
 end
end
