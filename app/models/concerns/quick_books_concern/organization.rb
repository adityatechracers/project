module QuickBooksConcern::Organization
  extend ActiveSupport::Concern
  included do 
    has_one :quick_books_session, dependent: :destroy
    has_one :expense_account, class_name:"QuickBooks::ExpenseAccount", dependent: :destroy
    has_one :income_account, class_name:"QuickBooks::IncomeAccount", dependent: :destroy
    has_one :quick_books_customer, class_name:"QuickBooks::Customer", dependent: :destroy
  end   
end   
