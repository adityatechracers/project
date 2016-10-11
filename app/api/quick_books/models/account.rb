module Api::QuickBooks::Models    
  class Account < Struct.new(:name, :classification, :account_type) 
    include Api::QuickBooks::Models::Base  
  end   
end   