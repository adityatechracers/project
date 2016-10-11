class LeadSourcesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def new

  end

  def create
    @lead_source.organization_id = if current_user.is_admin? then 0 else current_user.organization_id end
    if @lead_source.save
      redirect_to lead_sources_path, :notice => "Your lead source was added successfully"
    else
      render "new", :error => "Something went wrong..."
    end
  end

  def index
    @lead_sources = @lead_sources.not_deleted
  end

  def show

  end

  def edit

  end

  def update
    if !@lead_source.modifiable
      redirect_to :back, :alert => "You cannot modify this lead source."
    elsif @lead_source.update_attributes params[:lead_source]
      redirect_to lead_sources_path, :notice => "Your lead source was updated successfully"
    else
      render "new"
    end
  end

  def destroy
    if !@lead_source.modifiable
      redirect_to :back, :alert => "You cannot delete this lead source."
    elsif @lead_source.jobs.any?
      redirect_to :back, :alert => "You cannot delete a lead source that still has jobs attached to it!"
    else
      redirect_to lead_sources_path, :flash => {:success => "Your lead source has been deleted."} if @lead_source.destroy
    end
  end
end
