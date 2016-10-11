class QbProposalListener
  def qb_proposal_accepted proposal
    organization = proposal.organization
    session = organization.quick_books_session
    if session.present?
      Api::QuickBooks::QB.service(:customer) do 
        init company_id: session.company_id, organization:organization, proposal:proposal, contact:proposal.contact
        find_or_create_customer
        find_or_create_sub_customer
        create_estimate 
        create_sub_customer_invoice
        qb_send_invoice 
      end  
    end   
  end   
  def qb_new_progress_payment_invoice proposal, amount, description
    qb_new_payment_invoice :progress_payment, proposal, amount, description
  end 
  def qb_new_completion_payment_invoice proposal, amount
    qb_new_payment_invoice :completion_payment, proposal, amount
  end 
  private 
  def qb_new_payment_invoice type, proposal, amount, description=nil
    organization = proposal.organization
    session = organization.quick_books_session
    if session.present?
      Api::QuickBooks::QB.service(:customer) do 
        init company_id: session.company_id, organization:organization, proposal:proposal, contact:proposal.contact
        find_or_create_customer
        find_or_create_sub_customer
        create_payment_invoice type, amount, description
        qb_send_invoice 
      end  
    end   
  end   
end   