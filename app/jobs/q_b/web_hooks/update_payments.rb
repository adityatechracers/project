class Jobs::QB::WebHooks::UpdatePayments < Jobs::QB::WebHooks::BaseWebHooks
  class << self 
    def process 
      organizations.each do |organization| 
        begin
          in_transaction do 
            payments = Api::QuickBooks::Services::ChangeDataCapture::Payment.new organization 
            payments.changed(since).try do |changed_payments|
              changed_payments.each do |qb_payment|
                cork_payment = QuickBooks::Payment.where(quick_books_id:qb_payment.id)
                if cork_payment.present?
                  check_existing_payment qb_payment, organization
                else 
                  deleted = check_customer_deleted qb_payment, organization
                  unless deleted
                    payment_method_service =Api::QuickBooks::Services::PaymentMethod.new organization
                    add_new_payment(qb_payment, organization, payment_method_service)
                  end   
                end  
              end   
            end   
          end    
        rescue => error 
          p error.message
          @errors << "Update payments for organization (#{organization.id}) failed\n#{error.message}."
        end 
      end  
    end
    private
    def payment_info qb_payment, organization 
      qb_payment.customer_ref.try do |ref|
        cork_sub_customer = find_cork_sub_customer organization, ref.value
        proposal = cork_sub_customer.try(:proposal)
        if ref.name.match /Proposal #.*/ and proposal.present?
          return OpenStruct.new proposal:proposal, sub_customer_id:cork_sub_customer.id
        end 
      end       
    end   
    def check_customer_deleted qb_payment, organization
      ref = qb_payment.customer_ref
      if ref.name.match /\(deleted\)/ and qb_payment.total == 0
        cork_sub_customer = find_cork_sub_customer organization, ref.value
        if cork_sub_customer.present?
          cork_sub_customer.customer.destroy
        end   
      end   
    end   
    def find_cork_sub_customer organization, quick_books_id
      QuickBooks::SubCustomer.find_by_quick_books_id(organization, quick_books_id).first
    end  
    def check_existing_payment qb_payment, organization
      info = payment_info qb_payment, organization  

      #delete 
      unless info.present?
        QuickBooks::Payment.where(quick_books_id:qb_payment.id).destroy_all
      else   
        cork_payment = QuickBooks::Payment.find_by_quick_books_id qb_payment.id
        if cork_payment.present?
          #update existing
          qb_amount = qb_payment_amount qb_payment
          if cork_payment.amount != qb_amount 
            cork_payment.update_amount qb_amount
          end   
          qb_notes = qb_payment_notes qb_payment
          if cork_payment.notes != qb_notes 
            cork_payment.update_notes qb_notes
          end   
        end 
      end   
    end  
    def qb_payment_notes qb_payment 
      qb_payment.payment_ref_number
    end   
    def qb_payment_amount qb_payment 
      qb_payment.total
    end  
    def payment_type qb_payment, payment_method_service 
      payment_method_ref = qb_payment.payment_method_ref
      if payment_method_ref.present? 
        return payment_method_service.qb_get(payment_method_ref).name
      end    
      Payment::Types::UNSPECIFIED
    end   
    def add_new_payment qb_payment, organization, payment_method_service
      info = payment_info qb_payment, organization
      return unless info.present?
      proposal = info.proposal
      amount = qb_payment_amount(qb_payment)
      notes = qb_payment_notes(qb_payment)
      payment = Payment.create!(
        organization_id: proposal.organization_id,
        job_id: proposal.job_id,
        date_paid:qb_payment.txn_date,
        amount:amount,
        payment_type: payment_type(qb_payment, payment_method_service),
        notes: qb_payment_notes(qb_payment)
      )
      QuickBooks::Payment.create!(
        quick_books_id: qb_payment.id,
        sub_customer_id: info.sub_customer_id,
        amount: amount, 
        notes: notes,
        payment_id:payment.id
      )       
    end   
  end   
end   
