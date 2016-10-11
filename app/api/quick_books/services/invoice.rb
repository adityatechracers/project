module Api::QuickBooks::Services
  require_relative 'base'
  class Invoice < Base
    def create_deposit_invoice 
      @amount = @deposit_amount
      @item_ref = deposit_item_ref
      create_invoice QuickBooks::DepositInvoice, singleton:true
    end   
    def create_progress_payment_invoice amount, description 
      @amount = amount
      @description = description
      @item_ref = progress_payment_item_ref
      create_invoice QuickBooks::ProgressPaymentInvoice
    end   
     def create_completion_payment_invoice amount, description=nil
      @amount = amount
      @item_ref =  completion_payment_item_ref
      create_invoice QuickBooks::CompletionPaymentInvoice
    end   
    def send_invoice quick_books_id
      qb_invoice = service.fetch_by_id quick_books_id
      service.send qb_invoice
    end  
    protected
    def service_klass 
      Quickbooks::Service::Invoice
    end   
    private
    def create_invoice klass, opts={}
      @invoice = get_invoice(klass) if opts[:singleton]
      unless @invoice.present?
        qb_invoice = qb_invoice_from_model invoice_model
        created = service_create qb_invoice, singleton:opts[:singleton], find_by_key:"CustomerRef", find_by_value:@sub_customer_id
        @invoice = klass.create!(
          sub_customer_id:@cork_sub_customer_id, 
          quick_books_id:created.id,
          amount: @amount
        )
      end   
      @invoice
    end  
    def get_invoice klass
      klass.find_by_sub_customer_id @cork_sub_customer_id  
    end  
    def invoice_model 
      model = Api::QuickBooks::Models::Invoice.new(@sub_customer_id, @bill_email_address) 
      model.line_item @item_ref, @amount, @description, @proposal_url
      model
    end   
    def qb_model_klass 
      Quickbooks::Model::Invoice
    end   
    def qb_invoice_from_model model
      qb_model_from_model model 
    end  
  end
end 