class CreateQuickBooksEstimates < ActiveRecord::Migration
  def change
    create_table :quick_books_estimates do |t|
      t.integer :sub_customer_id, null:false
      t.string :quick_books_id, null:false
      t.timestamps
    end
    add_index :quick_books_estimates, :sub_customer_id
  end
end
