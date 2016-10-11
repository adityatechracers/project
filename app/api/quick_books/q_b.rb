module Api::QuickBooks
  class QB
    class << self 
      def access_token session 
        OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session.token, session.secret)
      end 
      def service type, &commands
        instance = Services.service(type)
        if instance.present? 
          @exception = nil
          ActiveRecord::Base.transaction do 
            begin 
            enable_logging
            instance.process &commands
            rescue => exception
              Rails.logger.error "Quick Books Api Error: #{exception.message}"
              @exception = exception 
              raise exception 
            ensure
              disable_logging    
            end 
          end
          raise @exception if @exception.present? 
        end   
      end   
      private 
      def log on
        Quickbooks.log = on unless Rails.env.production?
      end   
      def enable_logging
        log true 
      end 
      def disable_logging 
        log false
      end   
    end
  end      
end   