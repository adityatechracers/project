module QuickBooksAuthenticable
  extend ActiveSupport::Concern
  def qb_authentication_error?
    @qb_exception == :qb_authorization
  end   
  def catch_qb_auth_exception(options={render_json_error:true}) 
    begin 
      @qb_exception = nil
      yield
    rescue Quickbooks::AuthorizationFailure => error 
      @qb_exception = :qb_authorization
      if options[:render_json_error]
        render json: {error: @qb_exception}, status: :unprocessable_entity 
      end 
    end 
  end   
end
