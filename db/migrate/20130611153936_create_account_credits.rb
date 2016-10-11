class CreateAccountCredits < ActiveRecord::Migration
  def change
    create_table :account_credits do |t|
      t.decimal :amount, :precision => 9, :scale => 2
      t.integer :organization_id

      t.timestamps
    end
  end
end
