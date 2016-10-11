class StripeCallbacksController < ApplicationController

  protect_from_forgery :except => :create

  HANDLED_EVENTS = [
    'invoice.payment_succeeded',
    'invoice.payment_failed',
    # 'charge.succeeded',
    # 'charge.failed',
    'charge.dispute.created',
    'customer.subscription.created',
    'customer.subscription.updated',
    'customer.subscription.deleted',
    'customer.updated'
  ]

  def create
    event = params[:type]
    @params = params
    Activity.create(:event_type => event, :data => @params)
    return respond_ok unless can_handle?
    @organization = Organization.find_by_stripe_customer_token(get_customer_id)
    if @organization
      if HANDLED_EVENTS.include? event
        send(event.parameterize('_'))
      end
    end
    respond_ok
  end

  private

  def get_customer_id
    params[:data][:object].has_key?(:customer) ?
      params[:data][:object][:customer] : params[:data][:object][:id]
  end

  def can_handle?
    params.has_key?(:data) && params[:data].has_key?(:object) && get_customer_id.present?
  end

  def respond_ok
    render :json => {}, :status => :ok
  end

  def invoice_payment_failed
    @organization.payment_failed!
    SubscriptionsMailer.invoice_payment_failed(@organization).deliver
  end

  def invoice_payment_succeeded
    @organization.payment_succeeded!
    SubscriptionsMailer.invoice_payment_successful(@organization,@params[:data][:object][:total]).deliver
  end

  def charge_failed
    @organization.payment_failed!
    SubscriptionsMailer.charge_failed(@organization).deliver
  end

  def charge_succeeded
    @organization.payment_succeeded!
    SubscriptionsMailer.charge_successful(@organization, @params[:data][:object][:total]).deliver
  end

  def charge_dispute_created
    @organization.payment_failed!
    SubscriptionsMailer.charge_dispute_created(@organization).deliver
  end

  def customer_subscription_created
    SubscriptionsMailer.subscription_created(@organization, @params[:data][:object][:plan][:name]).deliver
  end

  def customer_subscription_updated
    if @organization.owner.present?
      plan = @params[:data][:object][:plan][:name]
      @organization.update_stripe_subscription_in_cork(plan) if @organization.stripe_plan_name != plan && @organization.stripe_plan_id != plan
      SubscriptionsMailer.subscription_updated(@organization, plan).deliver
    end
  end

  def customer_subscription_deleted
    @organization.failed_payment_cancellation
    if @organization.owner.present?
      SubscriptionsMailer.subscription_deleted(@organization).deliver
    end
  end

  def customer_updated
    if @params[:data][:previous_attributes].has_key? :account_balance
      amount = (@params[:data][:object][:account_balance] - @params[:data][:previous_attributes][:account_balance]) / 100
      AccountCredit.create(:organization_id => @organization.id, :amount => amount.abs)
    end
  end
end
