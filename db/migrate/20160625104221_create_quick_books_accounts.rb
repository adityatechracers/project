class CreateQuickBooksAccounts < ActiveRecord::Migration
  def change
    create_table :quick_books_accounts, {id:false} do |t|
      t.integer :organization_id, null:false
      t.string :quick_books_id, null:false
      t.string :type
      t.string :company_id, null:false
      t.timestamps
    end
    add_index :quick_books_accounts, ["organization_id", "company_id", "type"], name: :quick_books_accounts_id_index, unique: true
  end
end
