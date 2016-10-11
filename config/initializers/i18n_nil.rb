module I18n
  class << self
    alias_method :original_localize, :localize

    # Return an empty string when trying to localize a nil date (or other object).
    def localize object, options = {}
      object.present? ? original_localize(object, options) : ''
    end

    alias_method :l, :localize
  end
end
