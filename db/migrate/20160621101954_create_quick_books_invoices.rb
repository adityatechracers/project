class CreateQuickBooksInvoices < ActiveRecord::Migration
  def change
    create_table :quick_books_invoices do |t|
      t.integer :sub_customer_id, null:false
      t.string :quick_books_id, null:false
      t.string :type, null:false
      t.string :status, null:false
      t.decimal :amount, :precision => 8, :scale => 2, null:false
      t.timestamps
    end
    add_index :quick_books_invoices, :sub_customer_id
  end
end
