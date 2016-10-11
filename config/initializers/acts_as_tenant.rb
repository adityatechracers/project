# Tenancy is not used for admin users
# This is also set to support validates_uniqueness_to_tenant
ActsAsTenant.configure do |config|
  config.require_tenant = false
end
