class QuickBooks::SubCustomer < ActiveRecord::Base
  include QuickBooks::BaseRecord 
  belongs_to :customer, class_name:"QuickBooks::Customer", foreign_key: :customer_id
  attr_accessible :customer_id, :proposal_id, :display_name
  has_one :estimate, dependent: :destroy
  has_one :deposit_invoice, dependent: :destroy
  has_many :progress_payment_invoices, dependent: :destroy
  has_one :completion_payment_invoice, dependent: :destroy
  has_many :payments, class_name: "QuickBooks::Payment", dependent: :destroy
  has_many :expense_line_items, dependent: :destroy

  belongs_to :proposal
  validates :customer_id, :proposal_id, :display_name, presence: true
  def active_invoices 
    ([deposit_invoice] + progress_payment_invoices + [completion_payment_invoice]).compact.select do |invoice|
      !(invoice.deleted? || invoice.voided?)
    end  
  end   
  def self.find_by_quick_books_id organization, quick_books_id 
    organization_id = organization.id 
    company_id = organization.quick_books_session.company_id
    includes(:customer)
    .includes(customer: {organization: :quick_books_session})
    .where("quick_books_customers.organization_id = ?", organization_id)
    .where("quick_books_sessions.realm_id = ?", company_id)
  end  
  def paid_invoices 
    invoices.select {|invoice|invoice.paid?}
  end   
end
