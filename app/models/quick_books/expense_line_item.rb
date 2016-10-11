class QuickBooks::ExpenseLineItem < ActiveRecord::Base
  self.primary_keys =[ :qb_line_item_id, :qb_purchase_id]
  attr_accessible :qb_purchase_id, :qb_line_item_id, :sub_customer_id, :description
  validates :qb_purchase_id, :qb_line_item_id, :sub_customer_id, presence: true
  belongs_to :sub_customer, class_name:"QuickBooks::SubCustomer"
  include QuickBooks::UpdateableDescriptionAmount
  acts_as_updateable_description_amount belongs_to: :expense
end
 