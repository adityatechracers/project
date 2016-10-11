module Api::QuickBooks::Services::ChangeDataCapture
  require_relative 'change_data_capture_base'
  class Invoice < ChangeDataCaptureBase
    protected 
    def type
      "Invoice"
    end   
  end  
end   