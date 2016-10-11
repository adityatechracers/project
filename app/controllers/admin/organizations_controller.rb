module Admin
  class OrganizationsController < BaseController
    load_and_authorize_resource

    def index
      apply_filter if params.has_key? :filter
      @organizations = @organizations.includes(:owner).order(:name).page params[:page]
    end

    def show
      @account_credits = AccountCredit.where(:organization_id => @organization.id)
      return @invoices = [] unless @organization.stripe_customer_token?
      @invoices = Stripe::Invoice.all(:customer => @organization.stripe_customer_token).map do |c|
        c.created_at = Time.at(c.date)
        c
      end
    end

    # PUT /admin/organization/1
    # PUT /admin/organization/1.json
    def update
      respond_to do |format|
        if @organization.update_attributes(params[:organization])
          format.html { redirect_to admin_organization_path, notice: 'Organization was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { redirect_to admin_organization_path, notice: 'Organization could not be updated.' }
          format.json { render json: @organization.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /admin/organizations/1/apply_credit
    def apply_credit
      amount = params[:apply_credit][:amount].to_i
      unless amount > 0
        flash[:error] = 'Invalid Amount'
        return redirect_to admin_organization_path(@organization)
      end

      cu = Stripe::Customer.retrieve(@organization.stripe_customer_token)
      cu.account_balance -= amount * 100
      cu.save
      redirect_to admin_organization_path(@organization),
        :notice => "$#{amount}.00 has been applied to the account"
    end

    # PUT /admin/organizations/1/disable
    def disable
      begin
        @organization.cancel_subscription
      rescue Stripe::InvalidRequestError
        flash[:error] = %{The Stripe subscription could not be found and/or canceled.
                          If it was manually changed within Stripe, you can ignore this message.}
      end

      # In case there is no active subscription, we need to manually set the
      # active flag too.
      @organization.active = false
      @organization.save(:validate => false)
      redirect_to admin_organization_path(@organization), :notice => "Organization has been disabled"
    end

    # PUT /admin/organizations/1/enable
    def enable
      @organization.active = true
      @organization.save(:validate => false)
      redirect_to admin_organization_path(@organization),
        :notice => "Organization has been enabled. If there is no " +
          "active trial, the account owner will need to resubscribe."
    end

    def table
      apply_filter if params.has_key? :filter

      q = params[:query]
      if q.present?
        @organizations = @organizations.basic_search({:name => q, :address => q, :address_2 => q, :city => q, :region => q, :country => q, :zip => q, :email => q}, false)
      else
        @organizations = @organizations.includes(:owner).order(:name).page(params[:page])
      end

      render :partial => "table"
    end

    private

    def apply_filter
      case params[:filter]
      when 'trial'
        @organizations = @organizations
          .trials
          .where('trial_end_date > ?', Date.today)
      when 'active'
        @organizations = @organizations
          .active
          .paid
      when 'inactive'
        @organizations = @organizations
          .where('(trial_end_date <= ? AND stripe_plan_id = ?) OR active = ?', Date.today, 'Free', false)
      end
    end
  end
end
