module Api::QuickBooks::Models    
  class Invoice < Struct.new(:customer_id, :billing_email_address, :line_items) 
    def line_item deposit_ref, amount, description, proposal_url
      item = Quickbooks::Model::InvoiceLineItem.new line_num:1
      item.amount = amount
      prefix = description.present? ? description : ""
      prefix.sub!(/\.$/,'')
      prefix = prefix + ". " if prefix.present?
      item.description = "#{prefix}For details, view the proposal #{proposal_url}"
      item.sales_item! do |detail|
        detail.unit_price = amount
        detail.item_ref = Quickbooks::Model::BaseReference.new
        detail.item_ref.name = Api::QuickBooks::Services::Item::DEPOSIT
        detail.item_ref.value = deposit_ref
      end   
      self.line_items = [item] 
    end 
    include Api::QuickBooks::Models::Base  
  end   
end   