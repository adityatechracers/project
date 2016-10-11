class CreateQuickBooksItems < ActiveRecord::Migration
  def change
    create_table :quick_books_items, {id:false}  do |t|
      t.integer :organization_id, null:false
      t.string :quick_books_id, null:false
      t.string :name
      t.string :company_id, null:false
      t.timestamps
    end
    add_index :quick_books_items, ["organization_id", "company_id", "name"], name: :quick_books_items_id_index, unique: true
  end 
end
