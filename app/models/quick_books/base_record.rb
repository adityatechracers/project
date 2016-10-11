module QuickBooks::BaseRecord 
  extend ActiveSupport::Concern
  included do 
    validates  :quick_books_id, presence: true
    attr_accessible :quick_books_id
  end   
  module ClassMethods
    def belongs_to_organization
      setup_belongs_to_organization
    end  
    def belongs_to_organization_contact
      setup_belongs_to_organization
      belongs_to :contact
      attr_accessible :contact_id
      validates :contact_id, presence: true
    end  
    def organization_primary_keys
      [ :company_id, :organization_id]
    end   
    def belongs_to_sub_customer 
      belongs_to :sub_customer, class_name:"QuickBooks::SubCustomer"
      attr_accessible :sub_customer_id
      validates :sub_customer_id, presence: true
    end   
    private 
    def setup_belongs_to_organization
      belongs_to :organization
      acts_as_tenant :organization
      attr_accessible :organization_id, :company_id
      validates :organization_id, :company_id, presence: true
    end   
  end  
end
