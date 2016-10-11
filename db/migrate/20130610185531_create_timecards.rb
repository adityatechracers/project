class CreateTimecards < ActiveRecord::Migration
  def change
    create_table :timecards do |t|
      t.integer :job_id
      t.integer :organization_id
      t.integer :user_id
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.text :notes
      t.string :state
      t.decimal :amount, :precision => 9, :scale => 2
      t.float :duration
      t.decimal :pay_rate, :precision => 9, :scale => 2

      t.timestamps
    end
  end
end
