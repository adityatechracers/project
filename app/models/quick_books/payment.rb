class QuickBooks::Payment < ActiveRecord::Base
  include QuickBooks::BaseRecord 
  belongs_to_sub_customer
  attr_accessible :notes
  include QuickBooks::UpdateableDescriptionAmount
  acts_as_updateable_description_amount belongs_to: :payment, description_field: :notes  
end
 