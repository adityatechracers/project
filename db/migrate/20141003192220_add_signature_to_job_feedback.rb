class AddSignatureToJobFeedback < ActiveRecord::Migration
  def change
    add_column :job_feedbacks, :customer_sig, :text
  end
end
