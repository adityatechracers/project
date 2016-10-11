class Jobs::QB::WebHooks::UpdateExpenses < Jobs::QB::WebHooks::BaseWebHooks
  class << self 
    def process
      organizations.each do |organization| 
        begin
          in_transaction do 
            purchases = Api::QuickBooks::Services::ChangeDataCapture::Expense.new organization 
            purchases.changed(since).try do |changed_purchases|
              changed_purchases.each do |qb_purchase|
                cork_expense_line_items = QuickBooks::ExpenseLineItem.where(qb_purchase_id:qb_purchase.id)
                if cork_expense_line_items.present?
                  check_existing_line_items organization, qb_purchase, cork_expense_line_items
                else 
                  add_new_line_items qb_expense_line_items(organization, qb_purchase)
                end  
              end   
            end   
          end    
        rescue => error 
          p error.message
          @errors << "Update expense for organization (#{organization.id}) failed\n#{error.message}."
        end 
      end  
    end
    private
    def check_existing_line_items organization, qb_purchase, cork_expense_line_items
      cork_expense_line_item_ids = []
      cork_expense_map = cork_expense_line_items.inject({}) do |result, line_item|
        line_item_id = line_item.qb_line_item_id
        cork_expense_line_item_ids << line_item_id
        result[line_item_id] = line_item
        result
      end  
      line_items = qb_expense_line_items organization, qb_purchase 
      line_item_ids = line_items.map(&:qb_line_item_id)
      
      #delete 
      deleted = cork_expense_line_item_ids - line_item_ids
      QuickBooks::ExpenseLineItem.where(qb_purchase_id:qb_purchase.id, qb_line_item_id: deleted).destroy_all unless deleted.empty?
      
      #add new
      new_item_ids = line_item_ids - cork_expense_line_item_ids
      add_new_line_items select_line_items_by_id(line_items, new_item_ids)

      #update existing
      changes = line_item_ids & cork_expense_line_item_ids
      selected_changes = select_line_items_by_id line_items, changes
      selected_changes.each do |changed|
        cork_item = cork_expense_map[changed.qb_line_item_id]
        if cork_item.amount != changed.amount 
          cork_item.update_amount changed.amount 
        end  
        if cork_item.description != changed.description
          cork_item.update_description changed.description
        end    
      end   
    end  
    def select_line_items_by_id items, selected_line_item_ids
      items.select{|item| selected_line_item_ids.include?(item.qb_line_item_id)}
    end   
    def add_new_line_items new_items
      expense_attributes = [:organization_id, :job_id, :expense_date] 
      new_items.each do |new_item|
        expense = Expense.create! job_id:new_item.job_id, organization_id:new_item.organization_id, date_of_expense:new_item.expense_date, description:new_item.description, amount:new_item.amount
        item = new_item.to_h
        expense_attributes.each {|attribute| item.delete attribute}
        QuickBooks::ExpenseLineItem.create! item.merge({expense_id:expense.id})
      end   
    end  
    def qb_expense_line_items organization, qb_purchase
      line_items = []
      qb_purchase.line_items.each do |item|
        detail_type = item.detail_type.underscore
        customer = item.send(detail_type).customer_ref
        if customer.present?
          cork_sub_customer = QuickBooks::SubCustomer.find_by_quick_books_id(organization, customer.value).first
          proposal = cork_sub_customer.try(:proposal)
          if customer.name.match /Proposal #.*/ and proposal.present?
            line_items.push OpenStruct.new(
              qb_purchase_id: qb_purchase.id, 
              qb_line_item_id: item.id,
              sub_customer_id:cork_sub_customer.id, 
              amount: item.amount,
              organization_id: proposal.organization_id,
              job_id: proposal.job_id,
              expense_date:qb_purchase.txn_date,
              description: item.description
            )  
          end   
        end   
      end
      line_items
    end   
  end   
end   
