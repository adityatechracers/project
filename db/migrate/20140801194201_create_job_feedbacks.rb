class CreateJobFeedbacks < ActiveRecord::Migration
  def change
    create_table :job_feedbacks do |t|
      t.integer :job_id
      t.string :name
      t.text :feedback
      t.boolean :complete
      t.timestamps
    end
  end
end
