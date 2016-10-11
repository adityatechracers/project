class ExpenseCategoriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @expense_categories = @expense_categories.not_deleted
  end

  def new
    @expense_category = ExpenseCategory.new
  end

  def create
    @expense_category = current_user.organization.expense_categories.new(params[:expense_category])

    respond_to do |format|
      if @expense_category.save
        format.html { redirect_to expense_categories_path, notice: 'Expense category was successfully created.' }
        format.json { render json: @expense_category, status: :created, location: @expense_category }
      else
        format.html { render action: 'new' }
        format.json { render json: @expense_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @expense_category = ExpenseCategory.find(params[:id])
  end

  def update
    @expense_category = ExpenseCategory.find(params[:id])

    respond_to do |format|
      if @expense_category.update_attributes(params[:expense_category])
        format.html { redirect_to expense_categories_path, notice: 'Expense category was successfully updated' }
        format.json { render json: @expense_category, status: :created, location: @expense_category }
      else
        format.html { render action: 'edit' }
        format.json { render json: @expense_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @expense_category = ExpenseCategory.find(params[:id])

    respond_to do |format|
      if @expense_category.destroy
        format.html { redirect_to expense_categories_path, notice: 'Expense category was successfully deleted' }
        format.json { head :no_content }
      else
        format.html { redirect_to expense_categories_path, error: 'Expense category could not be deleted' }
        format.json { head :unprocessable_entity }
      end
    end
  end
end
