module Manage
  class SubscriptionsController < BaseController
    before_filter :authenticate_user!
    layout 'dashboard'

    def edit
      @organization = current_user.organization
      @enterprise_inquiry = Inquiry.new
    end

    def update
      params[:organization][:stripe_plan_name] = params[:organization][:stripe_plan_id]
      plan = Plan.new(params[:organization][:stripe_plan_id])
      num = plan.num_users
      @organization = current_user.organization
      if @organization.number_of_active_users <= num
        if @organization.update_attributes params[:organization]
          redirect_to manage_subscription_path, :notice => "Subscription successfully updated!"
        else
          if @organization.errors.messages[:card]
            flash[:error] = @organization.errors.messages[:card].first
          else
            flash[:warning] = 'Stripe reported an error while updating your card. Please try again.'
          end
          render :edit
        end
      else
        flash[:error] = "You have #{@organization.number_of_active_users} active users, which is above the limit of active users for this plan."   
      end  
    end

    def destroy
      @organization = current_user.organization
      @organization.cancel_subscription

      # Need to remove the org scope so we can use 'global' email templates
      ActsAsTenant.with_tenant(nil) { SubscriptionsMailer.cancelled_paid_account(@organization) }
      redirect_to manage_subscription_path, :notice => "Your account has been deactivated."
    end

    def edit_card
      @organization = current_user.organization
      @dont_alertify = true
    end

    def update_card
      @organization = current_user.organization
      if @organization.update_card(params[:organization][:stripe_card_token])
        flash[:success] = 'Billing info successfully updated.'
        redirect_to manage_edit_card_path
      else
        if @organization.errors.messages[:card]
          flash[:error] = @organization.errors.messages[:card].first
        else
          flash[:warning] = 'Stripe reported an error while updating your card. Please try again.'
        end
        render :edit_card
      end
    end
  end
end
