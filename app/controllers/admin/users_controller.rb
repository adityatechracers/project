require_relative "../concerns/exportable"
module Admin
  class UsersController < BaseController
    load_and_authorize_resource

    include Exportable

    def new
    end

    def create
      if @user.save
        redirect_to admin_users_path, :notice => "User created successfully"
      else
        render "new"
      end
    end

    def index
      apply_filter
      @users = @users.includes(:organization).order(:last_name).page params[:page]
    end

    def show
    end

    def edit
    end

    def export
      send_data generate_excel.stream.read, filename: 'export.xlsx', type: "application/xlsx"
    end

    def update
      if @user.update_attributes params[:user]
        redirect_to admin_users_path, :notice => "User updated successfully"
      else
        render "edit"
      end
    end

    def destroy
      redirect_to admin_users_path if @user.destroy
    end

    def become
      authorize! :become_user, :admin
      session[:become_last_id] = current_user.id
      session[:become_last_url] = request.referer
      sign_in(:user, User.find(params[:id]), :bypass => true)
      redirect_to dashboard_path
    end

    def table
      apply_filter if params.has_key? :filter

      q = params[:query]
      if q.present?
        @users = @users.basic_search({:first_name => q, :last_name => q, :address => q, :address2 => q, :city => q, :region => q, :country => q, :zip => q, :email => q}, false)
      else
        @users = @users.order(:last_name).page params[:page]
      end

      render :partial => "table"
    end

    private

    def generate_excel
      export_data do
        export = User.admin_export
        Utils::Excel.new.generate do
          sheet "Users"
          column export.columns
          rows export.rows
        end
      end
    end
    def apply_filter
      case params[:filter]
      when 'admin'
        @users = @users.where(:role => 'Admin')
      when 'owner'
        @users = @users.where(:role => 'Owner')
      when 'employee'
        @users = @users.where(:role => 'Employee')
      end
    end
  end
end
