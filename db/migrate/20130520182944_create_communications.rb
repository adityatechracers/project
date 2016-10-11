class CreateCommunications < ActiveRecord::Migration
  def change
    create_table :communications do |t|
      t.integer :job_id
      t.integer :user_id
      t.text :details
      t.string :outcome
      t.string :action
      t.datetime :datetime
      t.boolean :datetime_exact
      t.timestamps
    end
  end
end
