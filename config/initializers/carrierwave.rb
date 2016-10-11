CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => 'AKIAJ36O7YGBZMSTNHUA',
    :aws_secret_access_key  => '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',
  }
  config.fog_directory  = "corkcrm-#{Rails.env}"
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
end
