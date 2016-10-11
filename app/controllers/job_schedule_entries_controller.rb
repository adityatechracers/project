class JobScheduleEntriesController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  before_filter :set_jobs, only: [:modal, :new, :edit, :create, :update]
  helper :jobs

  def index
    @job_schedule_entries = JobScheduleEntry
      .accessible_by(current_ability)
      .includes(job: :contact)
      .includes(:crew)
    apply_date_range if params.has_key?(:start) && params.has_key?(:end)
    respond_to do |format|
      format.html
      format.json {
        calendar_entries = @job_schedule_entries
          .map(&:to_event)
          .concat(Job.includes(:contact).unscheduled_as_calendar_events)
        render json: calendar_entries
      }
    end
  end

  def new
    @job_schedule_entry = JobScheduleEntry.new
    if time = (Time.zone.parse(params[:date]) rescue false)
      @job_schedule_entry.start_datetime = time + 6.hours
      @job_schedule_entry.end_datetime = time + 18.hours
    end
    @job_schedule_entry.job = Job.find(params[:job]) if params[:job].present?
    set_crew
  end

  def create
    @job_schedule_entry = JobScheduleEntry.new(params[:job_schedule_entry])

    respond_to do |format|
      if @job_schedule_entry.save
        format.html { redirect_to :back, notice: 'Job schedule entry was successfully created.' }
        format.json { render json: @job_schedule_entry.to_event, status: :created, location: @job_schedule_entry }
      else
        if params[:modal_form]
          format.html { render partial: 'modal_form' }
        else
          format.html { render action: 'new' }
          format.json { render json: @job_schedule_entry.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def edit
    @job_schedule_entry = JobScheduleEntry.find(params[:id])
    set_crew
  end

  def update
    @job_schedule_entry = JobScheduleEntry.find(params[:id])

    respond_to do |format|

      if time = (Time.zone.parse(params[:job_schedule_entry][:start_datetime]) rescue false)
        params[:job_schedule_entry][:start_datetime] = time
      end
      if time = (Time.zone.parse(params[:job_schedule_entry][:end_datetime]) rescue false)
        params[:job_schedule_entry][:end_datetime] = time
      end

      if params[:job_schedule_entry][:start_datetime] != @job_schedule_entry.start_datetime
        # Job start time was updated so update job schedule entry stating that the mailer SHOULD send the notification
        params[:job_schedule_entry][:should_send_notification] = true
      end

      if @job_schedule_entry.update_attributes(params[:job_schedule_entry])
        format.html { redirect_to redirect_path, notice: 'Job schedule entry was successfully updated' }
        format.json { render json: @job_schedule_entry.to_event, status: :ok }
      else
        if params[:modal_form]
          format.html { render partial: 'modal_form' }
        else
          format.html { render action: 'edit' }
          format.json { render json: @job_schedule_entry.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @job_schedule_entry = JobScheduleEntry.find(params[:id])

    respond_to do |format|
      if @job_schedule_entry.destroy
        format.html { redirect_to jobs_path, notice: 'Entry has been removed from schedule' }
        format.json { head :no_content }
      else
        format.json { head :unprocessable_entity }
      end
    end
  end

  def modal
    @job_schedule_entry = params[:id] ? JobScheduleEntry.find(params[:id]) : JobScheduleEntry.new
    set_crew
    set_job
    render :partial => 'modal_form'
  end

  private

  def redirect_path
    case params[:redirect_to]
    when 'crew_calendar'
      crew_calendar_jobs_path
    else
      jobs_path
    end
  end

  def apply_date_range
    start_t = Date.parse(params[:start])
    end_t = Date.parse(params[:end])
    @job_schedule_entries = @job_schedule_entries.where('end_datetime >= ? and start_datetime <= ?', start_t, end_t)
  end

  def set_jobs
    @jobs = Job.with_accepted_proposal
      .not_completed
      .accessible_by(current_ability)
      .includes(:contact)
  end

  def set_job
    @job_schedule_entry.job_id = Job.find(params[:job]).id if params.has_key?(:job)
  end

  def set_crew
    # The pre-selected crew is resolved in this order:
    @crew = if params.has_key?(:crew)
              Crew.find(params[:crew])
            elsif @job_schedule_entry.new_record?
              @job_schedule_entry.job.try(:crew)
            else
              @job_schedule_entry.crew
            end
  end
end
