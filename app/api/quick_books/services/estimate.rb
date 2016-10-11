module Api::QuickBooks::Services
  require_relative 'base'
  class Estimate < Base
    def create_estimate 
      @estimate = QuickBooks::Estimate.find_by_sub_customer_id @cork_sub_customer_id  
      unless @estimate.present?
        qb_estimate = qb_estimate_from_model estimate_model
        created = service_create_singleton qb_estimate, find_by_key:"CustomerRef", find_by_value:@sub_customer_id
        @estimate = QuickBooks::Estimate.create!(
          sub_customer_id:@cork_sub_customer_id, 
          quick_books_id:created.id,
        )
      end   
    end   
    protected
    def service_klass 
      Quickbooks::Service::Estimate
    end   
    private 
    def estimate_model 
      model = Api::QuickBooks::Models::Estimate.new(:accepted, @accepted_date, @sub_customer_id) 
      model.line_item painting_services_item_ref, @proposal_url, @proposal_amount
      model
    end   
    def qb_model_klass 
      Quickbooks::Model::Estimate
    end   
    def qb_estimate_from_model model
      qb_model_from_model model 
    end  
  end
end 