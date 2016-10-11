module Admin
  class InvoicesController < BaseController
    def index
      authorize! :view_billing_history, :admin

      @per_page = 15
      options = invoice_options

      # Stripe ignores the customer filter if customer is nil, but we don't want that.
      return @invoices = [] if options.has_key?(:customer) && options[:customer] == nil

      @invoices = Stripe::Invoice.all(options).map do |c|
        c.organization = Organization.find_or_initialize_by_stripe_customer_token(c.customer)
        c.created_at = Time.at(c.date)
        c
      end
    end

    def show
      authorize! :view_billing_history, :admin

      @invoice = Stripe::Invoice.retrieve(params[:id])
      @customer = Stripe::Customer.retrieve(@invoice.customer)
      @charge = @invoice.charge.present? ? Stripe::Charge.retrieve(@invoice.charge) : nil
    end

    private

    def invoice_options
      options = {
        :date => {},
        :count => @per_page,
        :offset => params[:offset] || 0,
      }
      if date_range_filter_set?
        options[:date][:gte] = @date_range_filter_start.to_time.to_i
        options[:date][:lte] = @date_range_filter_end.end_of_day.to_time.to_i
      end
      options[:customer] = (@org = Organization.find(params[:org])).stripe_customer_token if params[:org]
      options
    end
  end
end
