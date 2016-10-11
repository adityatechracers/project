class Jobs::QB::WebHooks::UpdateInvoices < Jobs::QB::WebHooks::BaseWebHooks
  class << self 
    def process
      organizations.each do |organization| 
        begin 
          capture = Api::QuickBooks::Services::ChangeDataCapture::Invoice.new organization
          capture.changed(since).try do |changed|
            changed.each do |qb_invoice|
              cork_invoice = QuickBooks::Invoice.where(quick_books_id:qb_invoice.id).first
              if cork_invoice.present?
                case qb_invoice_status qb_invoice
                   when :voided
                    cork_invoice.voided!
                   when :deleted 
                    cork_invoice.deleted!
                   when :paid 
                    cork_invoice.paid! 
                   when :unpaid 
                    cork_invoice.unpaid! 
                   else
                    raise "invalid invoice status" 
                end   
              end  
            end   
          end   
        rescue => error 
          p error.message
          @errors << "Update invoice status for organization (#{organization.id}) failed\n#{error.message}."
        end 
      end  
    end
    private
    def qb_invoice_status qb_invoice 
      if qb_invoice.respond_to? :status
        return :deleted if qb_invoice.status == "Deleted"
      end   
      return :voided if qb_invoice.private_note == "Voided"
      return :paid if paid? qb_invoice
      return :unpaid if qb_invoice.balance > 0  
    end 
    def paid? qb_invoice
      qb_invoice.linked_transactions.map(&:txn_type).include? "Payment"
    end   
  end   
end   
