module Api::QuickBooks::Services
  require_relative 'base'
  class Item < Base
    PAINTING_SERVICES="Painting Services"
    DEPOSIT="Deposit"
    PROGRESS_PAYMENT= "Progress Payment"
    COMPLETION_PAYMENT= "Completion Payment"
    def painting_services_ref 
      find_or_create_painting_services.quick_books_id
    end 
    def deposit_ref 
      find_or_create_deposit.quick_books_id
    end   
    def progress_payment_ref 
      find_or_create_progress_payment.quick_books_id
    end  
    def completion_payment_ref 
      find_or_create_completion_payment.quick_books_id
    end   
    protected
    def service_klass 
      Quickbooks::Service::Item
    end   
    private 
    def find_or_create_painting_services
      find_or_create_item PAINTING_SERVICES
    end
    def find_or_create_deposit
      find_or_create_item DEPOSIT
    end
    def find_or_create_completion_payment
      find_or_create_item COMPLETION_PAYMENT
    end
    def find_or_create_progress_payment
      find_or_create_item PROGRESS_PAYMENT
    end
    def find_or_create_item name  
      @item = find_by_organization_and_company QuickBooks::Item.where(name:name)
      unless @item.present?
        qb_item = qb_item_from_model item_model(name)
        created = service_create_singleton qb_item, find_by_key:"Name", find_by_value: name
        @item = QuickBooks::Item.create!(
          name:name,
          organization_id:@organization.id,
          quick_books_id:created.id,
          company_id: @company_id
        )
      end  
      @item
    end    
    def item_model name
      Api::QuickBooks::Models::Item.new(name, 
        Quickbooks::Model::Item::SERVICE_TYPE,
        expense_account_ref,
        income_account_ref
      ) 
    end   
    def qb_model_klass 
      Quickbooks::Model::Item
    end   
    def qb_item_from_model model
      qb_model_from_model model
    end  
  end
end 