require 'bigdecimal'

# Serialize BigDecimal objects as JavaScript numbers (not strings).
# See possible side-effects here: https://github.com/rails/rails/issues/6033
class BigDecimal
  def as_json(options = nil) #:nodoc:
    if finite?
      self
    else
      NilClass::AS_JSON
    end
  end
end
