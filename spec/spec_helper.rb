# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/retry'
require 'capybara/rspec'
require 'capybara/poltergeist'
require "paperclip/matchers"
require 'database_cleaner'
require "awesome_print"
require 'devise'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

Capybara.javascript_driver = :poltergeist

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
    phantomjs_logger: StringIO.new,    # Silences JS console output. (Remove if you're debugging!)
    phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl-protocol=any']
  )
end


# Don't do any geocoding during within the tests.
class Contact
  def to_location; Graticule::Location.new; end
end

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include Devise::TestHelpers, :type => :controller
  config.include Paperclip::Shoulda::Matchers
  config.include FactoryGirl::Syntax::Methods
  config.include AuthHelpers
  config.include CheckPageHelpers
  config.include SelectionHelpers
  config.include CommonHelpers

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = false
  # config.use_transactional_examples = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.around(:each) do |example|
    DatabaseCleaner.start
    # Watch out for acts_as_tenant magic. If you log in within a spec, even
    # your Factory Girl create calls may be magically scoped to the logged in
    # user's organization, leading to unexpected behavior. I've nil-ed it out
    # here so that it at least can't interfere between specs.
    ActsAsTenant.current_tenant = nil
    create :quote
    example.run
    Capybara.reset_sessions!
    DatabaseCleaner.clean
  end

  # rspec-retry
  # config.default_retry_count = 3 # really means try up to 3 times
  # config.verbose_retry = true    # show retry status in spec process
end
