module Transactional
  def in_transaction 
    exception = nil
    ActiveRecord::Base.transaction do 
      begin 
        yield 
      rescue => e
        exception = e
        raise exception 
      end 
    end
    raise exception if exception.present?     
  end     
end 
