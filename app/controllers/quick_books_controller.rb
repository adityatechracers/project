class QuickBooksController < ApplicationController
  def authenticate
    callback = oauth_callback_quick_books_url
    token = QB_OAUTH_CONSUMER.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = token
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def bluedot
    access_token = session[:token]
    access_secret = session[:secret]
    consumer = OAuth::AccessToken.new(QB_OAUTH_CONSUMER , access_token, access_secret)
    response = consumer.request(:get, "https://appcenter.intuit.com/api/v1/Account/AppMenu")
    if response && response.body
      html = response.body
      halt 200, html
    end
  end
  
  def disconnect
    qb_session = current_user.organization.quick_books_session
    if qb_session.present?
      consumer = Api::QuickBooks::QB.access_token qb_session
      consumer.request(:get, "https://appcenter.intuit.com/api/v1/Connection/Disconnect")
      qb_session.destroy
    end
    head :ok
  end

  def oauth_callback
    at = session[:qb_request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:token] = at.token
    session[:secret] = at.secret
    session[:realm_id] = params[:realmId]
    qb_session = QuickBooksSession.first_or_initialize(organization_id:current_user.organization.id)
    qb_session.attributes = {
      token:at.token, 
      secret: at.secret,
      realm_id: params[:realmId]
    }
    qb_session.save!
    redirect_to success_quick_books_url
  end
  def success
    render layout:false
  end  
end
