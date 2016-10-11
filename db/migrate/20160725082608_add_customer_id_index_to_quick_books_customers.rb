class AddCustomerIdIndexToQuickBooksCustomers < ActiveRecord::Migration
  def up
    add_index :quick_books_customers, ["organization_id", "company_id", "contact_id"], name: :quick_books_customers_id_index, unique: true
  end
  def down
    remove_index :quick_books_customers, name: :quick_books_customers_id_index
  end   
end
