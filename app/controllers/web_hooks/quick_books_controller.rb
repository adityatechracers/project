module WebHooks
  class QuickBooksController < ActionController::Base
    include QuickBooksWebHooks
    
    before_filter :authenticate_with_quick_books_verifier! 
    rescue_from QuickBooksWebHooks::SignatureError, :with => :signature_error_handler

    def index
      Jobs::QB::WebHooks::WebHooksHandler.perform_async event_notifications
      head :ok
    end 
    private  
    def signature_error_handler(exception)
      p "Error: #{exception.message}"
      head :ok
    end   
    def event_notifications 
      params[:quick_book][:eventNotifications]
    end    
  end
end 
