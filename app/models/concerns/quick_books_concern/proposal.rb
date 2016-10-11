module QuickBooksConcern::Proposal
  extend ActiveSupport::Concern 
  include QuickBooksConcern::Base
  included do 
    has_one :sub_customer, class_name: "QuickBooks::SubCustomer"
    attr_accessor :qb_state_changed, :qb_proposal_state
    before_save do 
      self.qb_state_changed = self.proposal_state_changed?
      self.qb_proposal_state = self.proposal_state
      true
    end   
    after_save :publish_qb_proposal_accepted, if: :proposal_accepted?
  end 
  def qb_active_invoices 
    sub_customer.try(:active_invoices)
  end  
  def qb_paid_invoices 
    sub_customer.try(:paid_invoices)
  end   
  def qb_create_progress_payment_invoice amount, description
    publish_qb_new_progress_payment_invoice amount, description
  end   
  private
  def publish_qb_proposal_accepted
    broadcast(:qb_proposal_accepted, self)
  end 
  def publish_qb_new_progress_payment_invoice amount, description
    broadcast(:qb_new_progress_payment_invoice, self, amount, description)
  end  
  def state_changed?
    self.qb_state_changed || (self.qb_proposal_state != self.proposal_state)
  end  
  def proposal_accepted?
    state_changed? && self.accepted?
  end   
end   