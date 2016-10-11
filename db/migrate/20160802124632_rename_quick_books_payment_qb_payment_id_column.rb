class RenameQuickBooksPaymentQbPaymentIdColumn < ActiveRecord::Migration
  def change
    rename_index :quick_books_payments, "index_quick_books_payments_on_qb_payment_id", "index_quick_books_payments_on_quick_books_id"
    rename_column :quick_books_payments, :qb_payment_id, :quick_books_id
  end
end
