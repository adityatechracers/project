class CreateChangeOrders < ActiveRecord::Migration
  def change
    create_table :change_orders do |t|
      t.text :change_description
      t.integer :user_id
      t.integer :proposal_id
      t.integer :version_id

      t.decimal :proposal_amount_change, default: 0, precision: 9, scale: 2
      t.decimal :job_amount_change, default: 0, precision: 9, scale: 2
      t.integer :budgeted_hours_change, default: 0

      t.date :expected_start_date_new
      t.date :expected_end_date_new

      t.timestamps
    end
  end
end
