# == Schema Information
#
# Table name: job_schedule_entries
#
#  id                :integer          not null, primary key
#  job_id            :integer          not null
#  start_datetime    :datetime         not null
#  end_datetime      :datetime         not null
#  notes             :text
#  is_touch_up       :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  system_generated  :boolean          default(FALSE), not null
#  crew_id           :integer
#  sent_notification :boolean          default(FALSE), not null
#

require 'spec_helper'

describe JobScheduleEntry do
  pending "add some examples to (or delete) #{__FILE__}"
end
