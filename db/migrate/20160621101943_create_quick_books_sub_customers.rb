class CreateQuickBooksSubCustomers < ActiveRecord::Migration
  def change
    create_table :quick_books_sub_customers do |t|
      t.integer :customer_id, null:false
      t.belongs_to :proposal, null:false
      t.string :quick_books_id, null:false
      t.string :display_name, null:false
      t.timestamps
    end
    add_index :quick_books_sub_customers, :quick_books_id
    add_index :quick_books_sub_customers, :display_name
  end
end
