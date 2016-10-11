module WebAscender
  module Slugged
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def slugged(options = {})
        options[:slug] ||= :name
        options[:auto] ||= true
        options[:auto_override] ||= false

        # define_method(:to_param) do
        #   if self.slug.present?
        #     self.slug
        #   else
        #     self.id && self.id.to_s
        #   end
        # end

        if options[:auto]
          define_method(:automatic_slug) do
            if options[:auto_override] || !self.slug.present?
              self.slug = (self.send(options[:slug]) || "").parameterize
            end
          end

          before_validation :automatic_slug
        end
      end

      def find_by_slug(slug)
        self.where(:slug => slug).first || self.where(:id => slug).first
      end
    end
  end
end
