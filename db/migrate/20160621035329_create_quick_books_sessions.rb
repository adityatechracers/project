class CreateQuickBooksSessions < ActiveRecord::Migration
  def change
    create_table :quick_books_sessions do |t|
      t.belongs_to :organization,null: false
      t.string :secret,null: false
      t.string :token,null: false
      t.string :realm_id,null: false
      t.datetime :reconnect_at,null: false
      t.datetime :expires_at,null: false
      t.timestamps null: false
    end
    add_index :quick_books_sessions, :organization_id, unique:true
  end
end
