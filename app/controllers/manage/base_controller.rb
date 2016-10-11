class Manage::BaseController < ApplicationController
  before_filter :verify_user_can_manage

  def index
  end

  def website_embed
    if request.put?
      if current_tenant.update_attributes params[:organization]
        flash[:notice] = 'The embed options have been updated'
      else
        flash[:error] = 'The embed options could not be updated'
      end
      redirect_to :action => :website_embed
    end
  end

  private

  def verify_user_can_manage
    raise CanCan::AccessDenied unless current_user.try(:can_manage?)
  end
end
