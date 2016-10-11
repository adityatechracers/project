module Api::QuickBooks::Services::ChangeDataCapture
  class ChangeDataCaptureBase < Api::QuickBooks::Services::Base 
    def changed since=24.hours.ago
      service.try do |qb_service|
        qb_service.since([type], since).all_types[type]
      end   
    end     
    protected 
    def type
      raise NotImplementedError.new("Need to define change data type")
    end   
    def service_klass 
      Quickbooks::Service::ChangeDataCapture
    end      
  end  
end      
