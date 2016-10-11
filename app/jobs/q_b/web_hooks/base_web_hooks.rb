class Jobs::QB::WebHooks::BaseWebHooks < Jobs::BackgroundJob::Job 
  class << self 
    attr_accessor :options
    extend ConnectionPool
    with_connection :run
    protected  
    def run 
      process
    end
    def process 
    end      
    def organizations
      if options[:companies]
        QuickBooksSession
          .where(realm_id:options[:companies])
          .map(&:organization)
      else 
        Organization.all
      end   
    end   
    def since 
      (options[:since].try(:to_time) || 1.hour.ago) -5.minutes
    end   
  end     
end   