class JobFeedbackController < ApplicationController
  layout :set_layout
  before_filter :authenticate_user!, only: :index
  load_and_authorize_resource only: [:show, :destroy]

  def index
    @feedback_items = JobFeedback.accessible_by(current_ability)
      .order('created_at DESC')
      .page(params[:page])
  end

  def new
    @job = Job.find_by_guid!(params[:id])
    @job_feedback = @job.job_feedbacks.new
  end

  def show
  end

  def destroy
    redirect_to job_feedback_index_path if @job_feedback.destroy
  end

  def thanks
  end

  def create
    @job = Job.find_by_guid!(params[:id])
    @job_feedback = @job.job_feedbacks.new(params[:job_feedback])

    if @job_feedback.save
      render 'thanks', notice: 'Thanks for your feedback!'
    else
      render action: 'new'
    end
  end

  private

  def set_layout
    case params[:action]
    when 'index', 'show'
      'dashboard'
    else
      'print'
    end
  end
end
