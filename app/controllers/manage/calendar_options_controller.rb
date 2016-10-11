module Manage
  class CalendarOptionsController < BaseController
    before_filter :set_users

    def index
      @users = @users.page params[:page]
    end

    def set_calendar_options
      all_users_ids = @users.pluck(:id)
      users_ids_with_permission = []
      users_ids_with_permission = params['user_ids'].collect { |id| id.to_i } if params['user_ids']
      users_ids_without_permission = all_users_ids - users_ids_with_permission

      unless users_ids_with_permission.empty?
        User.update_all({can_be_assigned_appointments: true}, {id: users_ids_with_permission})
      end

      unless users_ids_without_permission.empty?
        User.update_all({can_be_assigned_appointments: false}, {id: users_ids_without_permission})
      end

      redirect_to manage_root_path
    end

    def set_users
      @users = User.where(organization_id: current_user.organization.id,
        active: true).order('can_be_assigned_appointments desc')
    end

  end
end