class ApplicationController < ActionController::Base

  protect_from_forgery
  layout :layout_by_resource
  set_current_tenant_through_filter
  prepend_before_filter :set_tenant
  before_filter :better_devise_flash
  before_filter :check_organization_status
  around_filter :org_time_zone
  before_filter :setup_date_range_filter
  before_filter :store_location
  before_filter :set_locale
  # before_filter :get_notifications
  before_filter :check_credit_card_expiration

  alias_method :devise_authenticate_user!, :authenticate_user!

  protected

  def authenticate_user!
    devise_authenticate_user!
    set_paper_trail_whodunnit
  end

  def check_credit_card_expiration
    exp_year = cookies['cc-expiration-year']
    exp_month = cookies['cc-expiration-month']
    unless exp_year && exp_month
      if current_user && current_user.organization && current_user.organization.stripe_customer_token.present?
        customer = Stripe::Customer.retrieve(current_user.organization.stripe_customer_token)
        cookies['cc-expiration-year'] =  { :value => customer.active_card.exp_year, :expires => 30.days.from_now }
        cookies['cc-expiration-month'] = { :value => customer.active_card.exp_month, :expires => 30.days.from_now}
      end
    end

    rescue Stripe::InvalidRequestError => e
      cookies.delete('cc-expiration-year')
      cookies.delete('cc-expiration-month')
  end

  def layout_by_resource
    devise_controller? ? 'application' : 'dashboard'
  end

  def after_sign_in_path_for(resource)
    base = current_user.try(:is_admin?) ? admin_root_path : dashboard_path
    request.env['omniauth.origin'] || session[:previous_url] || base
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def store_location
    # store last url as long as it isn't a /users path
    session[:previous_url] = request.fullpath unless request.fullpath =~ /\/|\/users/
  end

  rescue_from CanCan::AccessDenied do |exception|
    if current_user.try(:is_admin?)
      redirect_to admin_root_path, :notice => "You do not have permission to access this area or content."
    else
      redirect_to dashboard_path, :notice => "You do not have permission to access this area or content."
    end
  end

  def check_organization_status
    # Redirect to subscription page under certain conditions.
    # See also: User#active_for_authentication?
    return if current_tenant.nil? || current_tenant.is_paid_account?
    return if ['manage/subscriptions', 'devise/sessions'].include? params[:controller]
    return if params[:controller] == 'manage/users' && params[:action] == 'switch_back'
    if !current_tenant.active
      redirect_to manage_subscription_path,
        :notice => "This account is not active. Select a plan to keep using CorkCRM."
    elsif !current_tenant.trial_active?
      redirect_to manage_subscription_path,
        :notice => "Your free trial has expired. Select a plan to keep using CorkCRM."
    end
  end

  def set_tenant
    set_current_tenant(nil)
    return true unless current_user
    return true if current_user.is_admin?
    current_organization = current_user.organization
    set_current_tenant(current_organization)
  end

  def set_locale
    if current_user.present?
      I18n.locale = current_user.language
    else
      I18n.locale = http_accept_language.compatible_language_from(['en', 'fr-CA'])
    end
  end

  def org_time_zone(&block)
  # Use a specific timezone for the request
    if current_user.present? && current_user.organization.present?
      Time.use_zone(current_user.organization.time_zone, &block)
    # Try to set the timezone when the org guid is given (e.g. web embed).
    elsif params.has_key?(:org) && (org = Organization.find_by_guid(params[:org])).present?
      Time.use_zone(org.time_zone, &block)
    else
      block.call
    end
  end

  def setup_date_range_filter
    if date_range_filter_set?
      dates = params[:custom_date_range]

      if dates.split(',').length < 2
        dates = dates.split('%2C')
      else
        dates = dates.split(',')
      end

      @date_range_filter_start = Time.at(dates[0].to_i / 1000)
      @date_range_filter_end = Time.at(dates[1].to_i / 1000)
      @cdr_value = "#{@date_range_filter_start.strftime("%m/%d/%Y")} - #{@date_range_filter_end.strftime("%m/%d/%Y")}"
    end
  end

  def date_range_filter_set?
    params.has_key? :custom_date_range
  end

  def apply_date_range_filter(symbol, instance_var="@#{controller_name}")
    symbol = symbol.to_s
    if date_range_filter_set?
      records = (instance_variable_get(instance_var) || controller_name.classify.constantize)
        .where("#{symbol} BETWEEN ? AND ?", @date_range_filter_start, @date_range_filter_end)
      instance_variable_set(instance_var, records)
    end
  end

  def better_devise_flash
    if flash[:notice].present? and flash[:notice] == "Signed in successfully."
      flash[:notice] = nil
      flash.discard(:notice)
      flash.now[:success] = "Signed in successfully."
    end
  end

  def get_notifications
    if current_user and !current_user.is_admin?
      @todays_appointments = current_user.appointments.estimates.today.includes([{:job => :contact}])
      @todays_communications = current_user.communications.planned_for_today.includes([{:job => :contact}])
      @current_appointments = current_user.appointments.estimates.current.includes([{:job => :contact}])
      @current_communications = current_user.communications.current.includes([{:job => :contact}])
      @missed_communications = current_user.communications.missed.includes([{:job => :contact}])
      @notifications = @todays_appointments + @todays_communications + @current_appointments + @current_communications + @missed_communications
    end
  end

end
