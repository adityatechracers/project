module Api::QuickBooks::Models
  module Base   
    def params
      self.to_h 
    end   
    def from_struct struct, model 
      struct.each_pair {|k,v|model.send "#{k}=",v}
      model
    end   
  end  
end      
