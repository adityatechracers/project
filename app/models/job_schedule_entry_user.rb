class JobScheduleEntryUser < ActiveRecord::Base
  attr_accessible :job_schedule_entry_id, :user_id
  belongs_to :job_schedule_entry
  belongs_to :user
end

# == Schema Information
#
# Table name: job_schedule_entry_users
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  job_schedule_entry_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
