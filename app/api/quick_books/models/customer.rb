module Api::QuickBooks::Models  
  BillingAddress = Struct.new(:line1, :line2, :country_sub_division_code, :postal_code)
  class Customer < Struct.new(:given_name, 
      :family_name, 
      :display_name,
      :email_address,
      :primary_phone,
      :billing_address
      ) do 
      def phone number
        qb_number = Quickbooks::Model::TelephoneNumber.new
        qb_number.free_form_number = number 
        self.primary_phone = qb_number
      end 
      def set_billing_address contact 
        address = Quickbooks::Model::PhysicalAddress.new
        struct = BillingAddress.new(contact.address, contact.address2, contact.region, contact.zip)
        self.billing_address = from_struct struct, address
      end   
     end
    include Api::QuickBooks::Models::Base  
  end   
end   