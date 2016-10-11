module Api::QuickBooks::Models    
  class Item < Struct.new(:name, :type, :expense_account_id, :income_account_id) 
    include Api::QuickBooks::Models::Base  
  end   
end   