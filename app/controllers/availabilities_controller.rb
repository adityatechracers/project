class AvailabilitiesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @current_date = Time.zone.now.to_date
    @dates = (@current_date..(@current_date + 6)).to_a
    @employees = current_user.organization.users
  end

  def move_days
    @current_date = params[:date].to_date if params[:date]
    @dates = (@current_date..(@current_date + 6)).to_a
    render :partial => 'availabilities/days'
  end

  def available_employees
    @selected_date = params[:date].to_date if params[:date]
    all_users = users_by_availability(@selected_date)
    @employees = all_users.keep_if {|u| u.organization_id == current_user.organization.id}
    @current_employees = @employees.take(3)

    if params[:current_employees_ids].present? && params[:direction].present?
      current_employees_ids = params[:current_employees_ids].map {|id| id.to_i}
      @current_employees = move_employees(@employees, current_employees_ids, params[:direction])
    end

    render :partial => 'availabilities/available_employees'
  end

  def move_employees(org_employees, current_employees_ids, direction)
    @current_employees = org_employees.select {|e| e.id.in? current_employees_ids}
    if direction == "forward"
      last_employee_id = current_employees_ids.last
      last_employee_index = org_employees.index {|e| e.id == last_employee_id}
      employees_ahead_count = org_employees[(last_employee_index + 1)..org_employees.size].count
      case
      when employees_ahead_count >= 3
        @next_employees = org_employees[(last_employee_index + 1), 3]
      when employees_ahead_count == 2
        @next_employees = org_employees[(last_employee_index), 3]
      when employees_ahead_count == 1
        @next_employees = org_employees[(last_employee_index - 1), 3]
      else
        @next_employees = @current_employees
      end


    elsif direction == "back"
      first_employee_id = current_employees_ids.first
      first_employee_index = org_employees.index {|e| e.id == first_employee_id}
      employees_behind_count = org_employees[0...first_employee_index].count

      case
      when employees_behind_count >= 3
        @next_employees = org_employees[(first_employee_index - 3), 3]
      when employees_behind_count == 2
        @next_employees = org_employees[(first_employee_index - 2), 3]
      when employees_behind_count == 1
        @next_employees = org_employees[(first_employee_index - 1), 3]
      else
        @next_employees = @current_employees
      end
    end

    return @next_employees
  end

  def appointment_modal
    @appointment = params.has_key?(:appointment) ? Appointment.find(params[:appointment]) : Appointment.new
    @employee = params.has_key?(:employee) ? User.find(params[:employee]) : current_user
    @active_leads = Job.active_leads.accessible_by(current_ability).includes(:contact)
    @contact_rating = ContactRating.new
    @appointmentable_users = User.where(active: true, can_be_assigned_appointments: true)
    render :partial => 'appointment_form'
  end


  private
  def users_by_availability(date)
    pgresult = User.by_availability(date)
    fields = pgresult.fields

    users = pgresult.values.map { |value_set|
      User.instantiate(Hash[fields.zip(value_set)])
    }
    users
  end

end
