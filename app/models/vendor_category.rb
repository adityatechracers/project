# == Schema Information
#
# Table name: vendor_categories
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#

class VendorCategory < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name, :organization_id
  validates_presence_of :name, :organization_id
  validates_uniqueness_of :name, scope: :organization_id
  acts_as_tenant :organization

  has_many :expenses

end
