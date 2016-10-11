module Api::QuickBooks::Models    
  class Estimate < Struct.new(:txn_status, :accepted_date, :customer_id, :line_items) do 
      def line_item painting_services_ref, proposal_url, proposal_amount
        item = Quickbooks::Model::Line.new line_num:1
        item.amount = proposal_amount
        item.description = "For details, view the proposal #{proposal_url}"
        item.sales_item! do |detail|
          detail.quantity = 1
          detail.unit_price = proposal_amount
          detail.item_ref = Quickbooks::Model::BaseReference.new
          detail.item_ref.name = Api::QuickBooks::Services::Item::PAINTING_SERVICES
          detail.item_ref.value = painting_services_ref
        end   
        self.line_items = [item] 
      end 
    end 
    include Api::QuickBooks::Models::Base  
  end   
end   