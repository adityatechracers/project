class ExpensesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def new
    @job = Job.find(params[:job_id]) if params.has_key?(:job_id)
    @jobs = Job.includes(:contact).active
    @vendor_categories =  VendorCategory.not_deleted
    @expense_categories = ExpenseCategory.not_deleted
  end

  def create
    @expense.user_id = current_user.id
    if @expense.save
      redirect_to expenses_path, :notice => "The expense has been added"
    else
      render "new"
    end
  end

  def index
    page = params.has_key?(:page) ? params[:page] : 1
    apply_filter if params.has_key? :filter
    apply_date_range_filter :date_of_expense
    @expenses = @expenses.not_deleted.includes([{:job => [:contact]}, :expense_category, :vendor_category, :user]).order('date_of_expense DESC').page(page).per(20)

  end

  def edit
    @vendor_categories =  VendorCategory.not_deleted
    @expense_categories = ExpenseCategory.not_deleted
  end

  def expense_edit_jobs
    render partial: "job_collection"
  end
  
  def update
    if @expense.update_attributes params[:expense]
      redirect_to expenses_path, :notice => "The expense has been updated"
    else
      render "edit"
    end
  end

  def destroy
    if @expense.destroy
      redirect_to expenses_path, :notice => "The expense has been deleted"
    else
      redirect_to expenses_path, :flash => {:error => "The expense could not be deleted"}
    end
  end

  private

  def apply_filter
    today = Date.today
    case params[:filter]
    when 'today'
      @expenses = @expenses.where('date_of_expense = ?', today)
    when 'current_week'
      @expenses = @expenses.where('date_of_expense >= ? AND date_of_expense <= ?', today.beginning_of_week, today.end_of_week)
    when 'current_year'
      @expenses = @expenses.where('date_of_expense >= ? AND date_of_expense <= ?', today.beginning_of_year, today.end_of_year)
    end
  end
end
