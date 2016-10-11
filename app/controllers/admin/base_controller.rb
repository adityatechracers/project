class Admin::BaseController < ApplicationController
  before_filter :verify_admin

  def index
    @num_accounts = Organization.count
    @num_free_trials = Organization.trials.count
    # TODO: improve this by storing conversion date
    @num_conversions = Organization.where('stripe_plan_id != ?', 'Free')
      .where('trial_start_date >= ? AND trial_start_date <= ?', Date.today - 60.days, Date.today)
      .count
    @num_unsubscribers = Organization.trials
      .where('last_payment_date > ?', Date.today - 30.days)
      .count
    @num_failing_cards = Organization.where('last_payment_successful IS FALSE AND last_failed_payment_date IS NOT NULL').count

    # TODO: we have no (convenient) way to estimate the income from enterprise plans, as the cost is variable
    @estimated_income = Organization.where('stripe_plan_id != ?', 'Free')
      .map { |o| o.plan.monthly_cost.is_a?(Fixnum) ? o.plan.monthly_cost : 0 }
      .sum
  end

  def failing_cards
    authorize! :view_failing_credit_cards, :admin
    @organizations = Organization.where('last_payment_successful IS FALSE AND last_failed_payment_date IS NOT NULL')
  end

  def activity
    @activity = Activity.order('created_at desc')
  end

  def update_cms
    if params.has_key? :items and params[:items].any?
      params[:items].each do |item_id,content|
        item = PageItem.find(item_id)
        item.update_attributes!(:content => content) if item
      end
    end
    render :text => "OK!"
  end

  private

  def verify_admin
    raise CanCan::AccessDenied unless current_user.try(:is_admin?)
  end
end
