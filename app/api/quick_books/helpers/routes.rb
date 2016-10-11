module Api::QuickBooks::Helpers
  class Routes
    class << self 
      def proposal_url id 
        url_helpers.proposal_url id
      end 
      private
      def url_helpers 
        Rails.application.routes.url_helpers
      end 
    end   
  end 
end   