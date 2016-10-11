module Api::QuickBooks::Services
  class PaymentMethod < Api::QuickBooks::Services::Base 
    def qb_get id 
      service.fetch_by_id id 
    end   
    protected
    def service_klass 
      Quickbooks::Service::PaymentMethod
    end   
  end  
end      
