module Api::QuickBooks::Models    
  class SubCustomer < Struct.new(:display_name, :job, :parent_id, :email_address, :billing_address, :bill_with_parent) 
    include Api::QuickBooks::Models::Base  
  end   
end   