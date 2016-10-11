class CreateQuickBooksCustomers < ActiveRecord::Migration
  def change
    create_table :quick_books_customers, {id:false} do |t|
      t.string :ref, null:false
      t.belongs_to :organization,null: false
      t.string :company_id, null: false
      t.belongs_to :contact, null:false
      t.string :quick_books_id, null: false
      t.timestamps
    end
    add_index :quick_books_customers, :ref,  unique: true
    add_index :quick_books_customers, ["organization_id", "company_id"],  unique: true
  end
end
