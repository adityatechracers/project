class Jobs::QB::RenewExpiringTokens < Jobs::BackgroundJob::Job
  def self.run
    QuickBooksSession.expiring_sessions.each do |session|
      access_token = Api::QuickBooks::QB.access_token session
      service = Quickbooks::Service::AccessToken.new
      service.access_token = access_token
      service.company_id = session.realm_id
      result = service.renew
      if result.error_message.blank?
        # result is an AccessTokenResponse, which has fields +token+ and +secret+
        session.token = result.token
        session.secret = result.secret
        session.save!
      else 
        @errors << "Renew QuickBookSession(id #{session.id}) #{result.error_message}"
      end   
    end   
  end 
end   
