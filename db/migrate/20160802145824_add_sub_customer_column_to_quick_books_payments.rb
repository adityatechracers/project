class AddSubCustomerColumnToQuickBooksPayments < ActiveRecord::Migration
  def change
    add_column :quick_books_payments, :sub_customer_id, :integer, null:false
  end
end
