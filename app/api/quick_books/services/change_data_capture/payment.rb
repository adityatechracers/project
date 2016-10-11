module Api::QuickBooks::Services::ChangeDataCapture
  require_relative 'change_data_capture_base'
  class Payment < ChangeDataCaptureBase
    protected 
    def type
      "Payment"
    end   
  end  
end   