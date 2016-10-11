class AppointmentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:fetch_open, :fetch, :feed]
  load_and_authorize_resource
  skip_load_and_authorize_resource :only => [:fetch_open, :fetch, :feed]

  def index
    @appointment = Appointment.new
    apply_date_range if params.has_key?(:start) and params.has_key?(:end)
    @appointment_holders = User.find(@appointments.map(&:user_id).uniq)
    @appointments = @appointments.not_deleted
    if params.has_key? :who
      if params[:who] == "owner"
        @appointments = @appointments.with_owner
      elsif params[:who] == "employees" and params.has_key? :employees
        @appointments = @appointments.where(:user_id => params[:employees].split(","))
      end
    end

    @appointments = @appointments.includes(:user, :job => :contact) unless params[:who] == "employees" and params[:employees].nil?

    @current_user_google_calendars = fetch_user_google_calendars

    if params.has_key? :who and params[:who] == 'employees'
      @google_calendars = fetch_google_calendars
      @google_events = fetch_google_events
      @appointments = @appointments + @google_events
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @appointments.collect { |a| a.to_event } }
    end
  end

  def feed
    organization = Organization.find_by_guid!(params[:org])
    appointments = organization.appointments.not_deleted.where('start_datetime >= ?', Time.zone.now)
    appointments = appointments.where(:user_id => params[:user]) if params[:user].present?
    respond_to do |format|
      format.ics { render :text => generate_ical(appointments, organization) }
    end
  end

  def update
    # this information will define which action to execute on google calendar
    assigning_job = @appointment.job.nil? && params[:appointment][:job_id].present?
    unassigning_job = @appointment.job.present? && params[:appointment][:job_id].empty?

    respond_to do |format|
      if @appointment.update_attributes(params[:appointment])
        if current_tenant.show_customer_rating && params[:contact_rating]
          if params[:contact_rating][:rating_id].present? && params[:contact_rating][:contact_id].present?
            @contact_rating = ContactRating.where(:contact_id => params[:contact_rating][:contact_id], :stage => 'Appointment').first
            if !@contact_rating.blank?
              ContactRating.update(@contact_rating[:id],:rating_id => params[:contact_rating][:rating_id])
            else
              @contact_rating = ContactRating.new(params[:contact_rating])
              @contact_rating.save
            end
          end
        end

        if @appointment.user.connected_to_google?
          calendar = @appointment.user.google_calendars.shared.first.calendar_id
          if assigning_job
            push_appointment_to_google_calendar(@appointment, 'create', calendar)
          elsif unassigning_job
            push_appointment_to_google_calendar(@appointment, 'delete', calendar)
          elsif @appointment.job.present?
            push_appointment_to_google_calendar(@appointment, 'update', calendar)
          end
        end

        format.html { redirect_to appointments_path, notice: 'Appointment was successfully updated.' }
        format.json { render :json => @appointment.to_event, :status => :ok }
      else
        format.html { redirect_to appointments_path, notice: 'Appointment could not be updated.' }
        format.json { render json: @appointment.errors, :status => :unprocessable_entity }
      end
    end
    
    if params[:appointment][:job_id].present? && params[:appointment][:notes].present?
      @job = Job.find(params[:appointment][:job_id])
      @job.communications.create(:user_id => current_user.id, :action => 'Call', :type => 'CommunicationRecord', :details => params[:appointment][:notes], :datetime => DateTime.now, :datetime_exact => true)
    end
  end

  def destroy

    respond_to do |format|
      if @appointment.destroy
        if @appointment.user.connected_to_google? && @appointment.job.present?
          calendar = @appointment.user.google_calendars.shared.first.calendar_id
          push_appointment_to_google_calendar(@appointment, 'delete', calendar)
        end
        redirect_to appointments_path, :notice => "The appointment has been deleted"
        format.json { head :no_content }
      else
        redirect_to appointments_path, :error => "The appointment could not be deleted"
        format.json { head :unprocessable_entity }
      end
    end
  end

  def create
    @appointment.user_id ||= current_user.id

    respond_to do |format|
      if @appointment.save
        if current_tenant.show_customer_rating && params[:contact_rating]
          if params[:contact_rating][:rating_id].present? && params[:contact_rating][:contact_id].present?
            @contact_rating = ContactRating.where(:contact_id => params[:contact_rating][:contact_id], :stage => 'Appointment').first
            if !@contact_rating.blank?
              ContactRating.update(@contact_rating[:id],:rating_id => params[:contact_rating][:rating_id])
            else
              @contact_rating = ContactRating.new(params[:contact_rating])
              @contact_rating.save
            end
          end
        end
        if @appointment.user.connected_to_google? && @appointment.job.present?
          calendar = @appointment.user.google_calendars.shared.first.calendar_id
          push_appointment_to_google_calendar(@appointment, 'create', calendar)
        end
        format.html { redirect_to appointments_path, notice: 'The appointment was successfully created.' }
        format.json { render :json => @appointment.to_event, :status => :created }
      else
        p "Errors", @appointment.errors.full_messages
        format.html { redirect_to appointments_path, :notice => "The appointment could not be created" }
        format.json { render :partial => "appointments/modal_form.html", :status => :unprocessable_entity }
      end
    end

    if params[:appointment][:job_id].present? && params[:appointment][:notes].present?
      @job = Job.find(params[:appointment][:job_id])
      @job.communications.create(:user_id => current_user.id, :action => 'Call', :type => 'CommunicationRecord', :details => params[:appointment][:notes], :datetime => DateTime.now, :datetime_exact => true)
    end
  end

  def modal
    @appointment = params.has_key?(:id) ? Appointment.find(params[:id]) : Appointment.new
    @active_leads = Job.active_leads.accessible_by(current_ability).includes(:contact)
    @contact_rating = ContactRating.new
    @appointmentable_users = User.where(active: true, can_be_assigned_appointments: true)
    render :partial => 'modal_form'
  end

  def fetch_open
    @org = Organization.find_by_guid!(params[:org])
    @appointments = Appointment.not_deleted.includes(:job, :user).joins(:user).where(:organization_id => @org.id, :job_id => nil).all
    render json: @appointments.collect { |a| a.to_embedded_event }
  end

  def fetch
    @appointment = Appointment.find(params[:id])
    render json: @appointment.to_event
  end

  # Google calendar integration methods

  def fetch_user_google_calendars
    user_gcalendars = []
    if current_user.connected_to_google? && current_user.has_google_credentials?
      begin
        gcw = GoogleCalendarWrapper.new(current_user)
        gcw.import_calendars
        user_gcalendars = current_user.google_calendars
      rescue => e
        logger.error {"#{e.message} #{e.backtrace.join("\n")}"}
        current_user.update_attributes(connected_to_google: false)
        flash[:error] = "We were not able to fetch data from #{current_user.name}'s Google account."
      end
    end
    user_gcalendars
  end

  def fetch_google_calendars
    google_calendars = []
    employees_ids = []

    if params.has_key? :who and params[:who] == 'employees'
      employees_ids = params[:employees].split(",") if params.has_key? :employees
    end

    employees = User.where(id: employees_ids, connected_to_google: true)

    # fetch google calendars for each employee using his credentials
    employees.each do |employee|
      if employee.has_google_credentials?
        begin
          gcw = GoogleCalendarWrapper.new(employee)
          gcw.import_calendars
          google_calendars << employee.google_calendars
        rescue => e
          logger.error {"#{e.message} #{e.backtrace.join("\n")}"}
          employee.update_attributes(connected_to_google: false)
          flash[:error] = "We were not able to fetch data from #{employee.name}'s Google account."
        end
      end
    end

    google_calendars
  end

  def fetch_google_events
    google_events = []

    if params.has_key? :who and params[:who] == 'employees'
      employees_ids = params[:employees].split(",") if params.has_key? :employees
    end

    employees = User.where(id: employees_ids, connected_to_google: true)

    # handle events that come from google calendar
    employees.each do |employee|
      if employee.has_google_credentials?
        begin
          gcw = GoogleCalendarWrapper.new(employee)
          # shareable because we don't need to pull events from calendars that can't be shared
          calendars = employee.google_calendars.shareable
          calendars.each { |c| gcw.import_events(c.calendar_id) }
          google_events.concat(employee.google_events.not_canceled.from_shared_calendars)
        rescue => e
          logger.error {"#{e.message} #{e.backtrace.join("\n")}"}
          employee.update_attributes(connected_to_google: false)
          flash[:error] = "We were not able to fetch data from #{employee.name}'s Google account."
        end
      end
    end

    # from array to activerecord relation
    google_events = GoogleEvent.where(id: google_events.map(&:id)).includes(:user)

    if google_events.any?
      if params.has_key?(:start) and params.has_key?(:end)
        google_events = google_events.in_time_range(DateTime.strptime(params[:start], '%s'), DateTime.strptime(params[:end], '%s'))
      end
    end

    google_events
  end

  def push_appointment_to_google_calendar(appointment, action, calendar)
    user = appointment.user
    begin
      gcw = GoogleCalendarWrapper.new(user)
      gcw.push_event(appointment, action, calendar)
    rescue => e
      logger.error {"#{e.message} #{e.backtrace.join("\n")}"}
      user.update_attributes(connected_to_google: false)
    end
  end

  def google_disconnect
    current_user.update_attributes(connected_to_google: false) if current_user.connected_to_google?
    flash[:notice] = "Successfully disconnected from Google."
    redirect_to action: "index"
  end

  def get_contact_rating
    @rating_id = ContactRating.where(contact_id: params[:contact], stage: params[:stage]).first
    if @rating_id
      render :text => @rating_id.rating_id
    else
      render :text => 1
    end
  end

  private

  def apply_date_range
    start_t = DateTime.strptime(params[:start], '%s')
    end_t = DateTime.strptime(params[:end], '%s')
    @appointments = @appointments.collect{|a| a if a.start_datetime.to_date >= start_t && a.end_datetime.to_date <= end_t}.compact
    # change from array to activerecord::relation, otherwise the not_deleted method doesn't work
    @appointments = Appointment.where(id: @appointments.map(&:id))
  end

  def generate_ical(appointments, organization)
    RiCal.Calendar do |ical|
      ical.add_x_property 'X-WR-CALNAME', "#{organization.name} Appointments"
      ical.default_tzid = organization.time_zone
      appointments.each do |a|
        ical.event do |event|
          event.dtstart = a.start_datetime
          event.dtend = a.end_datetime
          event.summary = a.cal_title
          event.description = if a.notes.present? then a.notes else "" end
          event.add_attendee(a.user.email)
          event.add_attendee(a.job.contact.email) if a.job.present?
        end
      end
    end.export
  end
end
