module ActionView
  module Helpers
    module TranslationHelper
      alias_method :old_t, :t
      def t key, options = {}
        options[:raise] = false
        result = old_t key, options
        if result.respond_to? :gsub 
          result.gsub(/\<[^>]+\>/,'') 
        else
          result
        end  
      end   
    end 
  end 
end   
