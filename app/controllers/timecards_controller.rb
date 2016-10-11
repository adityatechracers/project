class TimecardsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  skip_load_and_authorize_resource :only => [:modal_form, :update_state]

  def new
    @timecard.user_id ||= current_user.id
    @timecard.job_id ||= Timecard.where(:user_id => current_user.id).last.try(:job_id)
  end

  def create
    @timecard.user_id ||= current_user.id
    respond_to do |format|
      if @timecard.save
        format.html { redirect_to timecards_path, :flash => {:success => 'The timecard was successfully created.'} }
        format.json { render :json => @timecard.to_event, :status => :created }
      else
        errors = @timecard.errors.full_messages.to_sentence
        format.html { render :new, :flash => {:alert => "The timecard could not be created"} }
        format.json { render :partial => "timecards/modal_form.html", json: errors, :status => :unprocessable_entity }
      end
    end
  end

  def index
    # Apply filters
    apply_date_range_filter :start_datetime
    @timecards = @timecards.not_deleted
    @timecards = @timecards.where(:state => params[:filter]) if params.has_key? :filter
    @timecards = @timecards.where(:user_id => params[:staff]) if params.has_key?(:staff) && current_user.can_manage?
    @timecards = @timecards.order("end_datetime DESC")
    @timecards = @timecards.includes([:user, {:job => :contact}]) if params.has_key?(:view) and params[:view] == "list"

    # Calculate totals of filtered group
    @total_hours = @timecards.sum(&:duration)
    @total_amount = @timecards.sum(&:amount)

    respond_to do |format|
      format.html
      format.json { render :json => @timecards.includes([:user, {:job => [:contact, :crew]}]).collect {|t| t.to_event} }
    end
  end

  def show
  end

  def edit
  end

  def update
    old_timecard = @timecard.dup
    respond_to do |format|
      if @timecard.update_attributes(params[:timecard])
        if should_send_change_notification?(old_timecard, @timecard)
          TimecardsMailer.change_notification(old_timecard, @timecard).deliver
        end
        format.html { redirect_to timecards_path, :flash => {:success => 'The timecard was successfully updated.'} }
        format.json { render :json => @timecard.to_event, :status => :ok }
      else
        errors = @timecard.errors.full_messages.to_sentence
        format.html { render 'edit', notice: 'Timecard could not be updated.' }
        format.json { render json: errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @timecard.destroy
        format.html { redirect_to :back, :notice => "The timecard has been deleted" }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, :error => "The timecard could not be deleted" }
        format.json { head :unprocessable_entity }
      end
    end
  rescue ActionController::RedirectBackError
    redirect_to timecards_path
  end

  def modal_form
    @timecard = params.has_key?(:id) ? Timecard.find(params[:id]) : Timecard.new
    @timecard.user_id ||= current_user.id
    @timecard.job_id ||= Timecard.where(:user_id => current_user.id).last.try(:job_id)
    render :partial => "timecards/modal_form"
  end

  def approve
    authorize! :approve, @timecard
    @timecard.update_attribute(:state, 'Approved')
    redirect_to :back, :notice => 'Your timecard has been approved'
  end

  def mark_paid
    authorize! :approve, @timecard
    @timecard.update_attribute(:state, 'Paid')
    redirect_to :back, :notice => 'Your timecard has been marked as paid'
  end

  def unapprove
    authorize! :approve, @timecard
    @timecard.update_attribute(:state, 'Entered')
    redirect_to :back, :notice => 'Your timecard has been unapproved'
  end

  def unmark_paid
    authorize! :approve, @timecard
    @timecard.update_attribute(:state, 'Approved')
    redirect_to :back, :notice => 'Your timecard has been unmarked as paid'
  end

  def update_state
    authorize! :approve, Timecard
    return redirect_to :back unless params[:state].in? Timecard::STATES

    params[:ids].split(',').each do |id|
      Timecard.find(id).update_attribute(:state, params[:state])
    end

    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to timecards_path
  end

  private

  def should_send_change_notification?(old, new)
    # Don't bother unless the user hasn't changed and isn't the current user
    old.user == new.user && current_user != old.user
  end
end
