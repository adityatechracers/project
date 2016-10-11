# == Schema Information
#
# Table name: change_orders
#
#  id                      :integer          not null, primary key
#  change_description      :text
#  user_id                 :integer
#  proposal_id             :integer
#  version_id              :integer
#  proposal_amount_change  :decimal(9, 2)    default(0.0)
#  job_amount_change       :decimal(9, 2)    default(0.0)
#  budgeted_hours_change   :integer          default(0)
#  expected_start_date_new :date
#  expected_end_date_new   :date
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'spec_helper'

describe ChangeOrder do
  pending "add some examples to (or delete) #{__FILE__}"
end
