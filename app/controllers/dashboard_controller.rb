class DashboardController < ApplicationController
  before_filter :authenticate_user!, :except => :get_regions
  layout 'dashboard'

  def index
    @this_week = Time.now.beginning_of_week..Time.now
    @this_year = Time.now.beginning_of_year..Time.now
  end

  def get_leads_stats
    @this_week = Time.now.beginning_of_week..Time.now
    @leads_ytd                   = Job.active_or_dead.from_time_range(Time.now.beginning_of_year, Time.now).count
    @leads_this_week             = Job.active_or_dead.from_time_range(Time.now.beginning_of_week, Time.now).count
    @appointments_ytd            = Appointment.estimates.updated_start_date(Time.now.beginning_of_year).count
    @appointments_this_week      = Appointment.estimates.updated_start_date(Time.now.beginning_of_week).count
    @slippage_ytd                = Job.dead_leads.from_time_range(Time.now.beginning_of_year, Time.now).count.to_f
    @slippage_this_week          = Job.dead_leads.from_time_range(Time.now.beginning_of_week, Time.now).count.to_f
    @slippage_percent_ytd        = @leads_ytd > 0 ? ( (@slippage_ytd / @leads_ytd) * 100 ).round : 0
    @slippage_percent_this_week  = @leads_this_week > 0 ? ( (@slippage_this_week / @leads_this_week) * 100 ).round : 0
    render :partial => 'leads_stats'
  end

  def get_proposals_stats
    @this_week = Time.now.beginning_of_week..Time.now
    @profit_this_year = number_to_currency Job.with_accepted_proposal.from_time_range(Time.now.beginning_of_year, Time.now).inject(0){|sum, a| sum + a.expected_profit}
    @profit_this_week = number_to_currency Job.with_accepted_proposal.from_time_range(Time.now.beginning_of_week, Time.now).inject(0){|sum, a| sum + a.expected_profit}

    @proposals_created_ytd            = Proposal.created_in_time_range(Time.now.beginning_of_year, Time.now).count
    @proposals_created_this_week      = Proposal.created_in_time_range(Time.now.beginning_of_week, Time.now).count

    @proposals_created_ytd_rev        = number_to_currency(Proposal.includes(:job).created_in_time_range(Time.now.beginning_of_year, Time.now).inject(0){|sum, a| sum + a.job.approved_proposals_amount}, :precision => 0)
    @proposals_created_this_week_rev  = number_to_currency(Proposal.includes(:job).created_in_time_range(Time.now.beginning_of_week, Time.now).inject(0){|sum, a| sum + a.job.approved_proposals_amount}, :precision => 0)

    @proposals_accepted_ytd        = Proposal.accepted.updated_in_time_range(Time.now.beginning_of_year, Time.now).count
    @proposals_accepted_this_week  = Proposal.accepted.updated_in_time_range(Time.now.beginning_of_week, Time.now).count
    @proposals_success_this_week   = @proposals_created_this_week > 0 ? ( ( @proposals_accepted_this_week / @proposals_created_this_week ) * 100 ).round : 0
    @proposals_success_ytd         = @proposals_created_ytd > 0 ? ( ( @proposals_accepted_ytd.to_f / @proposals_created_ytd ) * 100).round : 0

    @jobs_this_week_rev = Job.with_accepted_proposal.from_time_range(Time.now.beginning_of_week, Time.now).inject(0){|sum, a| sum + a.approved_proposals_amount}
    @jobs_ytd_rev = Job.with_accepted_proposal.from_time_range(Time.now.beginning_of_year, Time.now).inject(0){|sum, a| sum + a.approved_proposals_amount}

    render :partial => 'proposals_stats'
  end

  def get_jobs_stats
    @this_week = Time.now.beginning_of_week..Time.now
    @profit_this_year = number_to_currency(Job.with_accepted_proposal.from_time_range(Time.now.beginning_of_year, Time.now).inject(0){|sum, a| sum + a.expected_profit}, :precision => 0) 
    @profit_this_week = number_to_currency(Job.with_accepted_proposal.from_time_range(Time.now.beginning_of_week, Time.now).inject(0){|sum, a| sum + a.expected_profit}, :precision => 0) 
    @jobs_completed_ytd        = Job.completed.from_time_range(Time.now.beginning_of_year, Time.now).count
    @jobs_completed_this_week  = Job.completed.from_time_range(Time.now.beginning_of_week, Time.now).count
    @jobs_pending_ytd          = Job.in_working_period.from_time_range(Time.now.beginning_of_year, Time.now).count
    @jobs_pending_this_week    = Job.in_working_period.from_time_range(Time.now.beginning_of_week, Time.now).count

    @jobs_ytd_rev = Job.with_accepted_proposal.from_time_range(Time.now.beginning_of_year, Time.now).inject(0){|sum, a| sum + a.approved_proposals_amount}
    @jobs_ytd_count = Job.with_accepted_proposal.from_time_range(Time.now.beginning_of_year, Time.now).count
    @jobs_ytd_avg_size = number_to_currency(( @jobs_ytd_count != 0 ? ( @jobs_ytd_rev / @jobs_ytd_count ) : 0 ), :precision => 0) 

    @jobs_this_week_rev = Job.with_accepted_proposal.from_time_range(Time.now.beginning_of_week, Time.now).inject(0){|sum, a| sum + a.approved_proposals_amount}
    @jobs_this_week_count = Job.with_accepted_proposal.from_time_range(Time.now.beginning_of_week, Time.now).count
    @jobs_this_week_avg_size = number_to_currency((@jobs_this_week_count != 0 ? ( @jobs_ytd_rev / @jobs_this_week_count ) : 0), :precision => 0) 

    @jobs_pending_ytd_rev        = number_to_currency(Job.in_working_period.from_time_range(Time.now.beginning_of_year, Time.now).inject(0){|sum, a| sum + a.approved_proposals_amount}, :precision => 0) 
    @jobs_pending_this_week_rev  = number_to_currency(Job.in_working_period.from_time_range(Time.now.beginning_of_week, Time.now).inject(0){|sum, a| sum + a.approved_proposals_amount}, :precision => 0) 
    @jobs_completed_ytd_rev        = number_to_currency(Job.completed.from_time_range(Time.now.beginning_of_year, Time.now).inject(0){|sum, a| sum + a.approved_proposals_amount}, :precision => 0) 
    @jobs_completed_this_week_rev  = number_to_currency(Job.completed.from_time_range(Time.now.beginning_of_week, Time.now).inject(0){|sum, a| sum + a.approved_proposals_amount}, :precision => 0) 
    render :partial => 'jobs_stats'
  end

  def get_sales_stats
    @this_week = Time.now.beginning_of_week..Time.now
    @this_year = Time.now.beginning_of_year..Time.now
    @top_jobs_users = User.top_jobs_this_year.all
    render :partial => 'sales_table'
  end

  def get_footer
    @top_leads_users      = User.top_leads_this_year.all
    @top_calls_users      = User.top_calls_this_year.all
    @top_proposals_users  = User.top_proposals_this_year.all
    @top_jobs_users       = User.top_jobs_this_year.all
    @top_estimates_users  = User.top_estimates_this_year.all
    render :partial => 'dashboard_footer'
  end
  
  def get_regions
    params[:country] ||= "US"
    render :partial => "shared/region_options", :locals => {:country => params[:country]}
  end

end
