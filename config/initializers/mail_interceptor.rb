if defined? MailInterceptor
  options = { 
    forward_emails_to: 'michael@corkcrm.com'
  }

  if Rails.env.staging?
    interceptor = MailInterceptor::Interceptor.new(options)
    ActionMailer::Base.register_interceptor(interceptor)
  end
end   