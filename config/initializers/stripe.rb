# Load stripe config, either from config file or env variable
stripe_file_path = "#{::Rails.root.to_s}/config/stripe.yml"

if File.exist?(stripe_file_path)
  config = YAML.load_file(stripe_file_path)[::Rails.env]
  Stripe.api_key = config["secret_key"]
  STRIPE_PUBLIC_KEY = config["publishable_key"]
else
  Stripe.api_key = ENV['STRIPE_API_KEY']
  STRIPE_PUBLIC_KEY = ENV['STRIPE_PUBLISHABLE_KEY']
end

if !Stripe.api_key || !STRIPE_PUBLIC_KEY
    raise "Stripe config file not found, and stripe environment variables not set"
end
