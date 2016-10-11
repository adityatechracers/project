module Timezone
  class Zone 
    def self.from_active_support name 
      self.new zone: name
    end  
  end    
end    