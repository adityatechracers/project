class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :title
      t.integer :lead_source_id
      t.integer :contact_id
      t.text :details
      t.integer :probability
      t.string :state

      t.timestamps
    end
  end
end
