module QuickBooksWebHooks
  extend ActiveSupport::Concern
  require 'openssl'
  require 'base64'
  
  class SignatureError < StandardError; end
  ALGORITHM = 'sha256'
  def authenticate_with_quick_books_verifier! 
    payload = request_body
    expected_signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new(ALGORITHM), verifier, payload)).strip() 
    if signature_header != expected_signature
      raise SignatureError.new "Actual: #{signature_header}, Expected: #{expected_signature}"
    end
  end 
  private
  def verifier 
    QB_CONFIG[:webhooks][:verifier] 
  end   
  def request_body 
    request.body.rewind
    body = request.body.read
    request.body.rewind
    body
  end     
  def signature_header 
    request.headers['intuit-signature']
  end      
end
