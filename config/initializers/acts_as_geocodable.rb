# Monkey-patches ActsAsGeocodable after_save callback to more aggressively rescue errors.
module ActsAsGeocodable
  module Model
    alias_method :old_attach_geocode, :attach_geocode

    def attach_geocode
      old_attach_geocode
    rescue => e
      logger.warn e.message
    end
  end
end
