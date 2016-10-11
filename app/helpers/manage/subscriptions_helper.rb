module Manage::SubscriptionsHelper
  def plan_action_button(plan)
    if current_tenant.is_trial_account? || current_tenant.stripe_plan_id.nil?
      return link_to "Upgrade to #{plan.name}", "#",
        :class => 'btn btn-block btn-success subscription-button',
        :data => {:plan => plan.name.downcase, :active_users => current_tenant.number_of_active_users, :plan_users => plan.num_users}
    end

    if current_tenant.plan == plan
      link_to 'Cancel Subscription', manage_delete_subscription_path,
        :class => 'btn btn-block btn-danger', :method => :delete,
        :confirm => "Are you sure you want to cancel your subscription?"
    elsif current_tenant.plan.numeric_monthly_cost < plan.numeric_monthly_cost
      return link_to "Upgrade to #{plan.name}", "#",
        :class => 'btn btn-block btn-success subscription-button',
        :data => {:plan => plan.name.downcase}
    else
      return link_to "Downgrade to #{plan.name}", "#",
        :class => 'btn btn-block btn-warning subscription-button',
        :data => {:plan => plan.name.downcase}
    end
  end
end
