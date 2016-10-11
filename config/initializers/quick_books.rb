::QB_CONFIG = YAML.load(ERB.new(File.read("#{Rails.root}/config/quick_books.yml")).result)[Rails.env].with_indifferent_access

::QB_OAUTH_CONSUMER  = OAuth::Consumer.new(QB_CONFIG[:key], QB_CONFIG[:secret], {
    :site                 => "https://oauth.intuit.com",
    :request_token_path   => "/oauth/v1/get_request_token",
    :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
    :access_token_path    => "/oauth/v1/get_access_token"
})

unless Rails.env.production? 
  Quickbooks.sandbox_mode = true
end 
