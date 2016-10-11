module Jobs
  module BackgroundJob
    class Error < StandardError
      def initialize errors 
        @errors = errors 
      end 
      def data 
        {failed:@errors}
      end   
    end 
    class Job
      extend Transactional
      class << self
        def perform options={}
          @options = options
          @errors = []
          with_exception_handler do 
            run 
            if @errors.present?
              raise exception_class.new(@errors)
            end 
          end   
        end
        protected
        def run 
        end   
        def exception_class
          Error 
        end   
        private
        def with_exception_handler 
          begin 
            yield
          rescue => exception 
            data = {}
            data = exception.data if exception.respond_to? :data
            ExceptionNotifier::Notifier.background_exception_notification(
              exception,
              data: {job:self.name}.merge(data)
            ).deliver
          end    
        end   
      end 
    end   
  end   
end   