class CreateQuickBooksPayments < ActiveRecord::Migration
  def change
    create_table :quick_books_payments do |t|
      t.string :qb_payment_id, null:false, unique:true
      t.string :qb_sub_customer_id, null:false
      t.decimal :amount, :precision => 8, :scale => 2, null:false
      t.string :notes
      t.belongs_to :payment
      t.timestamps
    end
    add_index :quick_books_payments, :qb_payment_id, unique:true
  end
end
