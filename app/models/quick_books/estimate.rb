class QuickBooks::Estimate < ActiveRecord::Base
  include QuickBooks::BaseRecord 
  belongs_to_sub_customer 
end
