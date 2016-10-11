module QuickBooks
  def self.table_name_prefix
    'quick_books_'
  end
  require_relative 'quick_books/concerns/updateable_description_amount'
  require_relative 'quick_books/base_record'
  require_relative 'quick_books/customer'
  require_relative 'quick_books/sub_customer'
  require_relative 'quick_books/account'
  require_relative 'quick_books/expense_account'
  require_relative 'quick_books/income_account'
  require_relative 'quick_books/item'
  require_relative 'quick_books/estimate'
  require_relative 'quick_books/invoice'
end
