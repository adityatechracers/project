module QuickBooksConcern::Job
  extend ActiveSupport::Concern 
  include QuickBooksConcern::Base
  included do 
    attr_accessor :qb_state_changed
    before_save do 
      self.qb_state_changed = self.state_changed?
      true
    end   
    after_save :publish_new_completion_payment_invoice, if: :job_completed?
  end   
  def qb_invoiced_amount 
    proposal.try do |target|
      target.qb_active_invoices.try do |collection|
       collection.sum(&:amount)
      end   
    end || 0  
  end 
  def qb_paid_invoiced_amount
    proposal.try do |target|
      target.qb_paid_invoices.try do |collection|
       collection.sum(&:amount)
      end   
    end || 0  
  end   
  def qb_remaining_balance
    estimated_outstanding_balance - qb_invoiced_amount
  end   
  private 
  def publish_new_completion_payment_invoice
    broadcast(:qb_new_completion_payment_invoice, self.proposal, self.qb_remaining_balance)
  end 
  def job_completed?
    self.qb_state_changed && is_completed?
  end  
end   