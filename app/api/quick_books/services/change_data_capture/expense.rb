module Api::QuickBooks::Services::ChangeDataCapture
  require_relative 'change_data_capture_base'
  class Expense < ChangeDataCaptureBase
    protected 
    def type
      "Purchase"
    end   
  end  
end   