module Api::QuickBooks::Services
  require_relative 'base'
  class Account < Base
    def expense_account_ref 
      find_or_create(:expense_account).quick_books_id
    end  
    def income_account_ref 
      find_or_create(:income_account).quick_books_id
    end  
    private 
    NAME_PREFIX ="Painting Services"
    def self.account_name type 
      "#{NAME_PREFIX} #{type.to_s.titleize}"
    end
    public
    EXPENSE_ACCOUNT= account_name :expense_account 
    INCOME_ACCOUNT= account_name :income_account    
    protected
    def service_klass 
      Quickbooks::Service::Account
    end   
    private 
    def find_or_create type 
      name = self.class.account_name(type)
      @account = find_by_organization_and_company "QuickBooks::#{type.to_s.classify}".constantize
      unless @account.present?
        qb_account = qb_account_from_model account_model(type)
        created = service_create_singleton qb_account, find_by_key:"Name", find_by_value: name
        @account = account_klass(type).create!(
          organization_id: @organization.id,
          quick_books_id:created.id,
          company_id:@company_id
        )
      end
      @account
    end   
    def account_klass type 
      "QuickBooks::#{type.to_s.classify}".constantize
    end   
    def account_model_classification type 
      suffix = type == :expense_account ? "EXPENSE" : "REVENUE" 
      "Quickbooks::Model::Account::#{suffix}".constantize
    end
    def account_model_type type 
      type == :expense_account ? "Expense" : "Income" 
    end   
    def account_model type
      model = Api::QuickBooks::Models::Account.new(
        self.class.account_name(type), 
        account_model_classification(type), 
        account_model_type(type) 
      )  
      model
    end  
    def qb_model_klass 
      Quickbooks::Model::Account
    end  
    def qb_account_from_model model
      qb_model_from_model model
    end  
  end
end 