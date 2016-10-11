class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :job_id
      t.integer :organization_id
      t.date :date_paid
      t.decimal :amount, :precision => 9, :scale => 2
      t.string :payment_type
      t.string :notes

      t.timestamps
    end
  end
end
