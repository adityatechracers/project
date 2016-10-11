class RemoveOrganizationCompanyIndexFromQuickBooksCustomers < ActiveRecord::Migration
  def up
    remove_index :quick_books_customers, ["organization_id", "company_id"]
  end  
  def down 
    add_index :quick_books_customers, ["organization_id", "company_id"],  unique: true
  end   
end
