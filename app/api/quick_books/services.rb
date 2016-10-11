module Api::QuickBooks
  module Services
    require_relative "services/customer"
    require_relative "services/estimate"
    require_relative "services/item"
    require_relative "services/account"
    require_relative "services/invoice"
    require_relative "services/payment_method"
    require_relative "services/change_data_capture"
    def self.service type
      "Api::QuickBooks::Services::#{type.to_s.classify}".constantize.try(:new)
    end 
  end 
end      
