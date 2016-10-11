class AddQuickBooksIdIndexToQuickBooksCustomers < ActiveRecord::Migration
  def change
      QuickBooks::Customer.destroy_all
      add_index :quick_books_customers, ["organization_id", "company_id", "quick_books_id"], name: :quick_books_qb_id_index, unique: true
  end
end
