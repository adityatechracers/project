class CreateQuickBooksExpenseLineItems < ActiveRecord::Migration
  def change
    create_table :quick_books_expense_line_items, {id:false}  do |t|
      t.string :qb_purchase_id, null:false
      t.string :qb_line_item_id, null:false
      t.string :qb_sub_customer_id, null:false
      t.decimal :amount, :precision => 8, :scale => 2, null:false
      t.string :description
      t.belongs_to :expense
      t.timestamps
    end
    add_index :quick_books_expense_line_items, ["qb_purchase_id", "qb_line_item_id"], name: :purchase_line_item_id_index, unique: true
  end
end
