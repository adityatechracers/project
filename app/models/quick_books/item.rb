module QuickBooks
  class Item < ActiveRecord::Base
    include QuickBooks::BaseRecord 
    belongs_to_organization
    attr_accessible :name
    validates :name, presence: true
    self.primary_keys = [:name] + organization_primary_keys
  end
end 