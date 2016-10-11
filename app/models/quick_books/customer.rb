class QuickBooks::Customer < ActiveRecord::Base
  include QuickBooks::BaseRecord 
  belongs_to_organization_contact
  self.primary_keys = [:ref]
  attr_accessible :ref
  validates :ref, presence: true
  has_many :sub_customers, dependent: :destroy
end
