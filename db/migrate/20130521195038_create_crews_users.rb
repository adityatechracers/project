class CreateCrewsUsers < ActiveRecord::Migration
  def change
    create_table :crews_users do |t|
      t.integer :user_id
      t.integer :crew_id

      t.timestamps
    end
    add_index :crews_users, :user_id
    add_index :crews_users, :crew_id
  end
end
