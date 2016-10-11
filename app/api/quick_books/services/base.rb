module Api::QuickBooks::Services
  class Base
    def process &commands
      self.instance_eval &commands
      self
    end  
    def initialize organization=nil, options={}
      @organization = organization
      init options
    end   
    protected 
    def init options
      options.each do |key, value|
         instance_variable_set "@#{key.to_s}", value
      end   
      self
    end   
    def find_by_organization_and_company klass 
      klass.find_by_organization_id_and_company_id @organization.id, @company_id 
    end 
    def find_by_contact klass, contact_id 
      find_by_organization_and_company klass.where(contact_id:contact_id)
    end   
    def qb_model_klass
      raise NotImplementedError.new("Need to define quick books model class")
    end   
    def qb_model_from_model model
      qb_model = qb_model_klass.new
      set_qb_model qb_model, model 
      qb_model
    end  
    def init_service service
      qb_session = @organization.quick_books_session
      if qb_session.present?
        service.company_id = qb_session.realm_id
        service.access_token = Api::QuickBooks::QB.access_token qb_session
        return service
      end   
    end 
    def service 
      @service ||= new_service 
    end  
    def service_klass
      raise NotImplementedError.new("Need to define quick books service class")
    end   
    def new_service 
      init_service service_klass.new
    end  
    def new_estimate_service 
      service_new Api::QuickBooks::Services::Estimate
    end 
    def new_invoice_service 
      service_new Api::QuickBooks::Services::Invoice, company_id: @company_id
    end   
    def set_qb_model qb_model, model
      model.params.each_pair {|k,v| qb_model.send("#{k}=", v)}
    end  
    def painting_services_item_ref  
      new_item_service.painting_services_ref
    end 
    def deposit_item_ref  
      new_item_service.deposit_ref
    end 
    def completion_payment_item_ref  
      new_item_service.completion_payment_ref
    end
    def progress_payment_item_ref  
      new_item_service.progress_payment_ref
    end   
    def income_account_ref  
      new_account_service.income_account_ref
    end 
     def expense_account_ref  
      new_account_service.expense_account_ref      
    end 
    def service_create_singleton model, opts={}
      service_create model, opts.merge({singleton:true})  
    end   
    def service_create model, opts={}
      found = nil
      if opts[:singleton]
        filter = opts[:filter] || lambda {|collection| collection.first}
        found = filter.call service.find_by(opts[:find_by_key], opts[:find_by_value])
        if found.respond_to? :fully_qualified_name
          found = nil if found.fully_qualified_name.match /\(deleted/
        end   
      end 
      created = nil
      if found.present? 
        unless found.active? 
          service.update found, active:true
        end if found.respond_to? :active  
      else 
        created = service.create model  
      end 
      found || created  
    end 
    private 
    def service_new klass, opts={}
      klass.new @organization, opts
    end 
    def new_item_service 
      service_new Api::QuickBooks::Services::Item, company_id:@company_id
    end
    def new_account_service 
      service_new Api::QuickBooks::Services::Account, company_id:@company_id
    end        
  end
end 