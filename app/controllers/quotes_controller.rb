class QuotesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :verify_admin
  load_and_authorize_resource

  def new

  end

  def create
    if @quote.save
      redirect_to quotes_path, :notice => "Your quote has been added"
    else
      render "new"
    end
  end

  def index

  end

  def edit

  end

  def update
    if @quote.update_attributes params[:quote]
      redirect_to quotes_path, :notice => "Your quote has been updated"
    else
      render "edit"
    end
  end

  def destroy
    redirect_to quotes_path, :notice => "Your quote has been deleted" if @quote.destroy
  end

  private
  def verify_admin

  end

end
