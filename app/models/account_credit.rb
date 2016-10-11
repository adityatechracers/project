class AccountCredit < ActiveRecord::Base
  attr_accessible :amount, :organization_id
  acts_as_tenant :organization
end

# == Schema Information
#
# Table name: account_credits
#
#  id              :integer          not null, primary key
#  amount          :decimal(9, 2)
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
