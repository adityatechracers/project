class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def new
    @job = Job.find(params[:job_id], :include => :contact) if params.has_key?(:job_id)
  end

  def create
    if @payment.save
      redirect_to payments_path, :notice => "The payment has been added"
    else
      render "new"
    end
  end

  def index
    page = params.has_key?(:page) ? params[:page] : 1
    apply_filter if params.has_key? :filter
    apply_date_range_filter :date_paid
    @payments = @payments.not_deleted.includes(job: [:contact]).order('date_paid DESC').page(page).per(20)
  end

  def edit
  end

  def update
    if @payment.update_attributes params[:payment]
      redirect_to payments_path, :notice => "The payment has been updated"
    else
      render "edit"
    end
  end

  def destroy
    if @payment.destroy
      redirect_to payments_path, :notice => "The payment has been deleted"
    else
      redirect_to payments_path, :flash => {:error => "The payment could not be deleted"}
    end
  end

  private

  def apply_filter
    today = Date.today
    case params[:filter]
    when 'today'
      @payments = @payments.where('date_paid = ?', today)
    when 'current_week'
      @payments = @payments.where('date_paid >= ? AND date_paid <= ?', today.beginning_of_week, today.end_of_week)
    when 'current_year'
      @payments = @payments.where('date_paid >= ? AND date_paid <= ?', today.beginning_of_year, today.end_of_year)
    end
  end
end
