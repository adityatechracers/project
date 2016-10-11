class QuickBooks::Account < ActiveRecord::Base
  include QuickBooks::BaseRecord 
  belongs_to_organization
  self.primary_keys = [:type] + organization_primary_keys
end
