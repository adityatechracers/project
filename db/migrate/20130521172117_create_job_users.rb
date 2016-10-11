class CreateJobUsers < ActiveRecord::Migration
  def change
    create_table :job_users do |t|
      t.integer :user_id
      t.integer :job_id

      t.timestamps
    end
    add_index :job_users, :user_id
    add_index :job_users, :job_id
  end
end
