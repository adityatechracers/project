module QuickBooksConcern
  module Base
    include Wisper::Publisher
  end 
  require_relative 'quick_books_concern/proposal' 
end   
