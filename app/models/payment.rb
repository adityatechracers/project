class Payment < ActiveRecord::Base
  attr_accessible :amount, :date_paid, :job_id, :notes, :organization_id, :payment_type
  belongs_to :job
  acts_as_tenant :organization
  module Types
    UNSPECIFIED="Unspecified"
  end
  validates_presence_of :job_id, :amount

  scope :in_range, lambda { |range| where(date_paid: range) }

  include QuickBooksConcern::Payment

  def amount=(num)
    self[:amount] = num.to_s.scan(/\b-?[\d.]+/).join.to_f
  end
end

# == Schema Information
#
# Table name: payments
#
#  id              :integer          not null, primary key
#  job_id          :integer
#  organization_id :integer
#  date_paid       :date
#  amount          :decimal(9, 2)
#  payment_type    :string(255)
#  notes           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#
