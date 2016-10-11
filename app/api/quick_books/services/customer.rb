module Api::QuickBooks::Services
  require_relative 'base'
  QB = ::QuickBooks
  class Customer < Base
    def find_or_create_customer options={}
      contact_id = @contact.id 
      @customer = find_by_contact QB::Customer, contact_id
      created = nil 
      create_customer = lambda do
        qb_customer = qb_customer_from_model customer_model
        created = service_create_singleton qb_customer, find_by_key: :display_name, find_by_value:customer_model.display_name
      end 
      if options[:check_active] 
        create_customer.call
      end  
      if created or @customer.blank?
        create_customer.call
        ref="#{@organization.id}:#{@company_id}:#{contact_id}"
        @customer.destroy if @customer.present?
        @customer = QB::Customer.create! ref:ref, contact_id: contact_id, company_id: @company_id, organization_id:@organization.id, quick_books_id:created.id
        p "new customer #{@customer.inspect}"
      end 
    end   
    def find_or_create_sub_customer
      tried = 0
      1.times.each do 
        @sub_customer_display_name = sub_customer_display_name
        @sub_customer = @customer.sub_customers.where(display_name:@sub_customer_display_name).first 
        unless @sub_customer.present?
          qb_sub_customer = qb_customer_from_model sub_customer_model
          error = nil
          begin 
            created = service_create_singleton qb_sub_customer, find_by_key: :display_name, find_by_value:@sub_customer_display_name
          rescue Quickbooks::IntuitRequestException => exception 
            error = exception
          end   
          if error.present? 
            if error.message.match /Please make the parent customer active first/ 
              if tried == 0
                tried = 1
                find_or_create_customer check_active:true
                redo
              end 
            else 
              raise error    
            end 
          end   
          @sub_customer = QB::SubCustomer.create!(
            customer_id:@customer.ref, 
            proposal_id:@proposal.id,
            quick_books_id:created.id,
            display_name: @sub_customer_display_name
          )
        end   
      end  
    end 
    def create_estimate
      estimate_service.create_estimate
    end 
    def create_sub_customer_invoice
      if @proposal.deposit_amount > 0
        @invoice = invoice_service.create_deposit_invoice 
      end 
    end 
    def create_payment_invoice type, amount, description 
      raise "#{type.to_s.humanize} amount mst be greater than 0" if amount == 0
      @invoice = invoice_service.send "create_#{type.to_s}_invoice", amount, description
    end 
    def qb_send_invoice 
      invoice_service.send_invoice @invoice.quick_books_id if @invoice.present?
    end   
    private 
    def filter_by_quick_books_id
      if @customer.present? 
        lambda do |collection|
          found = nil
          collection.find_index {|member| (found = member and true) if member.id == @customer.quick_books_id}
          found 
        end   
      end   
    end   
    def sub_customer_display_name 
      "Proposal ##{@proposal.proposal_number}"
    end   
    def sub_customer_model 
      customer = customer_model 
      Api::QuickBooks::Models::SubCustomer.new(@sub_customer_display_name, 
        true, 
        @customer.quick_books_id, 
        customer.email_address,
        customer.billing_address,
        true
      )
    end   
    def qb_model_klass
      Quickbooks::Model::Customer
    end   
    def qb_customer_from_model model
      qb_model_from_model model 
    end  
    def customer_display_name 
      "#{@contact.name} - #{@contact.id}"      
    end   
    def customer_model 
      model = Api::QuickBooks::Models::Customer.new(
        @contact.first_name, @contact.last_name, 
        customer_display_name, 
        @contact.email
      ) 
      model.phone  @contact.phone
      model.set_billing_address @contact
      model
    end   
    def service_klass
      Quickbooks::Service::Customer
    end 
    def estimate_service 
      @estimate_service ||= new_estimate_service.init( 
        accepted_date:@proposal.created_at, 
        proposal_url: proposal_url,
        proposal_amount: @proposal.amount,
        sub_customer_id:@sub_customer.quick_books_id,
        cork_sub_customer_id:@sub_customer.id,
        company_id:@company_id
      )
    end   
    def invoice_service 
      @invoice_service ||= new_invoice_service.init(
        bill_email_address: customer_model.email_address , 
        deposit_amount:@proposal.deposit_amount, 
        proposal_url: proposal_url,
        company_id: @company_id,
        sub_customer_id:@sub_customer.quick_books_id,
        cork_sub_customer_id:@sub_customer.id
      )
    end   
    def proposal_url 
      Api::QuickBooks::Helpers::Routes.proposal_url(@proposal.id)
    end   
  end
end 