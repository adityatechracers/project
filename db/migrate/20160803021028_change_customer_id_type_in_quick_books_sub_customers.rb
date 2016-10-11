class ChangeCustomerIdTypeInQuickBooksSubCustomers < ActiveRecord::Migration
  def up
    remove_column :quick_books_sub_customers, :customer_id
    add_column :quick_books_sub_customers, :customer_id, :string
  end  
  def down
     remove_column :quick_books_sub_customers, :customer_id
     add_column :quick_books_sub_customers, :customer_id, :integer 
  end   
end
