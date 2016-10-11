class ExpenseCategory < ActiveRecord::Base
  attr_accessible :name, :organization_id, :major_expense
  validates_presence_of :name, :organization_id
  validates_uniqueness_of :name, scope: :organization_id
  acts_as_tenant :organization

  has_many :expenses

  scope :major, -> { where(major_expense: true) }
end

# == Schema Information
#
# Table name: expense_categories
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#  major_expense   :boolean          default(FALSE), not null
#
