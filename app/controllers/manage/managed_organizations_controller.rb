module Manage
  class ManagedOrganizationsController < BaseController
    def index
      @managed_organizations = current_tenant.child_organizations
    end

    def become
      cookies[:become_last_email] = current_user.email
      sign_in(:user, User.find(params[:id]), :bypass => true)
      redirect_to dashboard_path
    end
  end
end
