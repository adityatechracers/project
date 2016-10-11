class AddInstructionsDisplayedToJobFeedback < ActiveRecord::Migration
  def change
    add_column :job_feedbacks, :instructions_displayed, :text
  end
end
