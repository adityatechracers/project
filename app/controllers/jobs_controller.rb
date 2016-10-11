class JobsController < ApplicationController
  load_and_authorize_resource :except => 'schedule'
  before_filter :authenticate_user!
  helper :timecards, :proposals
  helper_method :sort_column, :sort_direction
  before_filter :setup_crew_calendar, only: [:crew_calendar, :crew_calendar_row]

  rescue_from ActionController::RedirectBackError do |exception|
    logger.error {"#{e.message} #{e.backtrace.join("\n")}"}
    redirect_to jobs_path
  end

  include QuickBooksAuthenticable

  def index
    page = params.has_key?(:page) ? params[:page] : 1
    @jobs = @jobs.not_deleted.includes(:proposals, :contact, :crew, :organization, :activities).where('proposals.proposal_state = ?', 'Accepted')
    @jobs = apply_ordering(apply_filters(@jobs))
    @jobs = Kaminari.paginate_array(@jobs) if @jobs.is_a?(Array)
    @jobs = @jobs.page(page).per(10)
  end

  def send_invoice
    amount = Float(params[:amount])
    if amount > 0
      catch_qb_auth_exception do
         @job.send_invoice(amount, params[:description])
      end
    end
    head :ok unless @qb_exception
  end
  def new_invoice_modal
    @proposal = @job.proposal
    @contact = @proposal.contact
    @previously_invoiced = @job.qb_invoiced_amount
    @remaining_balance = @job.qb_remaining_balance
    render  "new_invoice_modal", layout:false
  end
  def table
    page = params.has_key?(:page) ? params[:page] : 1
    @contacts = Contact.not_deleted
    unless params[:query].blank?
      fields = [:first_name, :last_name, :address, :address2, :city, :region, :country, :zip, :phone, :email ]
      search_params = Hash[fields.map { |f| [f, params[:query]] }]
      @contacts = @contacts.basic_search(search_params, false)
    end

    @jobs = Job.not_deleted.includes(:proposals, :contact, :crew, :next_communication).where('proposals.proposal_state = ?', 'Accepted').where('contact_id in (?)',@contacts)
    @jobs = apply_ordering(apply_filters(@jobs))

    @jobs_filtered = Job.not_deleted.includes(:proposals, :contact, :crew, :next_communication).where('proposals.proposal_state = ?', 'Accepted')

    @job_ids = []
    @jobs_filtered.each do |j|
      @job_ids << j.id
    end

    @jobs_by_title = []
    unless params[:query].blank?
      fields_job = [:title]
      search_params_job= Hash[fields_job.map { |f| [f, params[:query]] }]
      @jobs_by_title = Job.not_deleted.basic_search(search_params_job, false)

      @jobs_by_title = @jobs_by_title.where('id in (?)',@job_ids)
      @jobs_by_title = apply_ordering(apply_filters(@jobs_by_title))
    end

    @jobs_by_proposal_number = []
    unless params[:query].blank?
      @proposals_by_number = []
      fields_prop = [:proposal_number]
      search_params_prop = Hash[fields_prop.map { |f| [f, params[:query]] }]
      @proposals_by_number = Proposal.not_deleted.basic_search(search_params_prop, false)

      @jobs_by_proposal_number = Job.not_deleted.includes(:proposals, :contact, :crew, :next_communication).where('proposals.proposal_state = ?', 'Accepted').where('proposals.id in (?)', @proposals_by_number)
    end

    @jobs = @jobs + @jobs_by_title + @jobs_by_proposal_number
    @jobs = @jobs.uniq if @jobs.is_a?(Array)
    @jobs = Kaminari.paginate_array(@jobs) if @jobs.is_a?(Array)
    @jobs = @jobs.page(page).per(10)
    render :partial => "table"
  end

  def schedule
    @jobs = Job.accessible_by(current_ability).includes(:contact)
    @crews = Crew
      .not_deleted
      .order(:name)
      .push(OpenStruct.new(id: 0, name: t('jobs.misc.no_crew_assigned'), color: '#ccc'))
  end

  def crew_calendar
    @crews = Crew.not_deleted.order(:name).push(*@crews)
    @jobs_starting_this_week = Job.job_scheduled_to_start(@week)
    if @jobs_starting_this_week.any?
      @total_dollars = @jobs_starting_this_week.map{|job| job.approved_proposals_amount.to_f}.reduce(:+)
    else
      @total_dollars = 0
    end
  end

  def crew_calendar_row
    if params[:crew_id]
      @crews = Crew
        .not_deleted
        .where(id:params[:crew_id]) if params[:crew_id].present?
    else
      @crews = [OpenStruct.new(id: nil, name: t('jobs.misc.no_crew_assigned'), color: '#ccc')]
    end
    render partial: "crew_calendar_rows"
  end
  def create
    respond_to do |format|
      if @job.save
        format.html { redirect_to jobs_path, notice: 'The job has been added.' }
        format.json { render :json => @job, :status => :created }
      else
        format.html { render :index, :error => "The could not be created" }
        format.json { render :json => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def show
  end

  def update
    respond_to do |format|
      if @job.update_attributes(params[:job])
        format.html { redirect_to jobs_path, notice: 'Job was successfully updated.' }
        format.json { render :json => @job, :status => :ok }
      else
        format.html { redirect_to jobs_path, notice: 'Job could not be updated.' }
        format.json { render json: @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    redirect_to jobs_path, :notice => "Your job has been successfully deleted." if @job.destroy
  end

  def modal
    @show_crew_help = can?(:create, Crew) && !Crew.any?
    @job = params.has_key?(:id) ? Job.find(params[:id]) : Job.new
    @job.estimated_amount = @job.calculated_amount unless @job.estimated_amount.present? and @job.estimated_amount > 0
    render :partial => 'modal_form'
  end

  def fetch
    render :json => Job.find(params[:id]).to_json(:include => :contact), :status => :ok
  end

  def mark_dead
    if @job.update_attribute(:dead, true)
      redirect_to :back, :notice => "Your #{(@job.state == "Lead") ? "lead" : "job"} has been marked as dead"
    else
      redirect_to :back, :error => "Something went wrong..."
    end
  end

  def mark_undead
    if @job.update_attribute(:dead, false)
      redirect_to :back, :notice => "Your job has been marked active"
    else
      redirect_to :back, :error => "Something went wrong..."
    end
  end

  def complete
    completed = false
    catch_qb_auth_exception(render_json_error:false) do
      completed = @job.update_attributes(:state => "Completed")
    end
    if completed
      JobsMailer.job_complete(@job).deliver
      session[:contact_id] = @job.contact_id
      session[:job_completed] = true
      redirect_to :back, :notice => "Your job has been marked as completed"
    else
      error_message = "Something went wrong..."
      if qb_authentication_error?
        error_message = "Quick books authentication failed, you may try to reconnect then repeat your action."
      end
      flash[:error] = error_message
      redirect_to :back
    end
  end

  def uncomplete
    last_state = @job.last_state_change_activity.data[:from]
    # FIXME: last_state can be 'Completed', leaving it trapped in that state
    last_state = "Scheduled" if last_state == "Completed"
    if @job.update_attributes(:state => last_state)
      redirect_to :back, :notice => "Your job has been unmarked as completed"
    else
      redirect_to :back, :error => "Something went wrong..."
    end
  end

  def request_client_feedback
    JobsMailer.job_client_feedback_request(@job).deliver
    redirect_to :back, :notice => "An email has been sent to #{@job.contact.email}."
  rescue
    flash[:error] = 'The email could not be sent. Make sure the "Job Client Feedback Request" template is enabled.'
    redirect_to :back
  end

  def find_by_address
    @contact = Contact.advanced_search(:address => params[:address].split(", ").join(" | "))
    render :text => @contact.any? ? @contact.first.jobs.last.id : 0
  end

  def contact_rating
    if current_tenant.show_customer_rating
      if !params[:contact_rating][:rating_id].empty? && !params[:contact_rating][:contact_id].empty?
        @contact_rating = ContactRating.where(:contact_id => params[:contact_rating][:contact_id], :stage => 'Completion').first
        if !@contact_rating.blank?
          ContactRating.update(@contact_rating[:id],:rating_id => params[:contact_rating][:rating_id])
        else
          @contact_rating = ContactRating.new(params[:contact_rating])
          @contact_rating.save
        end
      end
    end
    redirect_to :back
  end

  private

  def setup_crew_calendar
    @week_offset = (params[:week] || 0).to_i
    @week = (Date.today.beginning_of_week(:sunday) + @week_offset.weeks..Date.today.end_of_week(:sunday) + @week_offset.weeks)
    @week_start = @week.first
    @week_end = @week.last
    @entries = JobScheduleEntry
      .accessible_by(current_ability)
      .includes(job: :contact)
      .where('? <= end_datetime AND start_datetime <= ?', @week.begin, @week.end + 1.day)

    @crews =[
      OpenStruct.new(id: nil, name: t('jobs.misc.no_crew_assigned'), color: '#ccc'),
      OpenStruct.new(id: 'all-crews', name: t('jobs.misc.all_crews'), color: '#ccc')
     ]
  end

  def apply_filters(jobs)
    return jobs.where(:state => 'Accepted') unless params.has_key?(:filter)

    case params[:filter]
    when 'unscheduled'
      jobs.where(:state => "Accepted")
    when 'scheduled'
      jobs.where(:state => "Scheduled")
    when 'completed'
      jobs.where(:state => "Completed")
    when 'all'
      jobs.where(:state => ["Accepted", "Scheduled", "Completed"])
    end
  end

  def apply_ordering(jobs)
    case sort_column
    when 'expected_end_date', 'expected_start_date'
      # Calculating these is non-trivial, so it's cleanest (if slowest) to sort in Ruby.
      sorted = jobs.all.sort_by { |j| j.send(sort_column, true) || Date.new }
      sorted = sorted.reverse if sort_direction == 'desc'
      sorted
    else
      jobs.order("jobs.#{sort_column} #{sort_direction}")
    end
  end

  def sort_column
    return params[:sort] if params[:sort].in? ['expected_start_date', 'expected_end_date']
    Job.column_names.include?(params[:sort]) ? params[:sort] : 'title'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
