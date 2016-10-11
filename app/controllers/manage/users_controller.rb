module Manage
  class UsersController < BaseController
    load_and_authorize_resource except: [:become, :switch_back]
    skip_before_filter :verify_user_can_manage, only: :switch_back

    def new
      @user.set_appointments_color
      if not @user.organization.can_add_users?
        redirect_to manage_users_path,
          :notice => "Your account does not support additional users.
                      #{view_context.link_to('Upgrade your account', manage_subscription_path)}".html_safe
      end
    end

    def create
      @user.assign_attributes(
        role: @user.role.in?(['Employee', 'Manager']) ? @user.role : 'Employee', # Can only make employees and managers
        language: @user.organization.language,
        password: Devise.friendly_token.first(8)
      )
      if not @user.organization.can_add_users?
        redirect_to manage_users_path, :notice => "Could not save user. Upgrade your account to add new users."
      elsif @user.save
        UsersMailer.new_organization_user(@user, @user.password).deliver
        redirect_to manage_users_path, :notice => "Your user has been created"
      else
        render "new"
      end
    end

    def update
      if @user.update_attributes params[:user]
        if params[:user][:image].present?
          render :crop  ## Render the view for cropping
        else
          @user.image = params[:image]    
          @user.save if params[:user][:image_crop_x].present?
          redirect_to manage_users_path, :notice => "User updated successfully"
        end
      else
        render "edit"
      end
    end

    def index
      @users = @users.order(:last_name).page params[:page]
    end

    def become
      @user = User.unscoped.find(params[:id])

      if @user.active
        # See ability file. Depends on current user's role and the organization
        # the target user belongs to.
        raise CanCan::AccessDenied unless current_ability.can?(:become, @user)

        session[:become_last_id] = current_user.id
        session[:become_last_url] = request.referer
        sign_in(:user, @user, :bypass => true)
        redirect_to dashboard_path
      else
        redirect_to manage_users_path, :flash => {:error => "user is inactive"}
      end
    end

    def switch_back
      sign_in(:user, User.unscoped.find(session[:become_last_id]), :bypass => true)
      redirect_path = session[:become_last_url] || dashboard_path
      session.delete(:become_last_id)
      session.delete(:become_last_url)
      redirect_to redirect_path
    end
  end
end
