class QuickBooksSession < ActiveRecord::Base
  belongs_to :organization
  acts_as_tenant :organization
  attr_accessible :organization_id, :token, :secret, :realm_id
  validates :organization_id, :token, :realm_id, :secret, :expires_at, :reconnect_at, presence: true
  before_validation(on: :create) do
    self.expires_at = QB_CONFIG[:expires_in].from_now
    self.reconnect_at = QB_CONFIG[:reconnects_in].from_now
  end
  def self.expiring_sessions
    where("reconnect_at <= ?", Time.now.utc)
  end  
  def company_id
    realm_id
  end  
end
