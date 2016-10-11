class JobFeedback < ActiveRecord::Base
  attr_accessible :name, :feedback, :instructions_displayed, :complete, :customer_sig
  belongs_to :job
  after_create :email_sales_people

  validates_presence_of :name
  paginates_per 10

  private

  def email_sales_people
    JobsMailer.job_feedback_notice(self.job, self).deliver
  end
end

# == Schema Information
#
# Table name: job_feedbacks
#
#  id                     :integer          not null, primary key
#  job_id                 :integer
#  name                   :string(255)
#  feedback               :text
#  complete               :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  customer_sig           :text
#  instructions_displayed :text
#
