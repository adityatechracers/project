module Manage
  class ReportsController < BaseController
    before_filter :authenticate_user!
    helper :timecards
    helper :proposals

    def index
    end

    def leads
      #unless date_range_filter_set?
      #  params[:custom_date_range] = "#{(Time.now - 30.days).to_i * 1000},#{Time.now.to_i * 1000}"
      #  setup_date_range_filter
      #end
      @results = Job.active.includes(contact: [:geocoding])
      @line_chart_data = if date_range_filter_set?
                           @results = @results.from_time_range(@date_range_filter_start, @date_range_filter_end)
                           Job.group_by_day(:created_at, :range => @date_range_filter_start..@date_range_filter_end).count
                         else
                           @results.group_by_day(:created_at).count
                         end
      @contact_coordinate_data = @results.all(joins:{contact:{geocoding:[:geocode]}}).map{|l|l.contact.map_data}.to_json
      @transcended_count = @results.transcended.count
      @dead_count = @results.dead_leads.count
      @lead_source_distribution = LeadSource.all.map {|ls| [ls.locale_name, @results.where(:lead_source_id => ls.id).count]}
      @results = @results.leads
      @lead_count = @results.count
      @lead_status_distribution = [
        [t('manage.reports.leads.active_leads'),      @lead_count],
        [t('manage.reports.leads.transcended_leads'), @transcended_count],
        [t('manage.reports.leads.dead_leads'),        @dead_count]
      ]
    end

    def timesheets
      @users = User.not_deleted.joins(:timecards).group('users.id').all
      @results = Timecard
      @results = @results.where(:user_id => params[:user]) if params.has_key? :user
      @results = @results.where(:state => params[:status].split.map(&:capitalize)) if params.has_key? :status
      @line_chart_data = if date_range_filter_set?
                           @results = @results.from_time_range(@date_range_filter_start, @date_range_filter_end)
                           @results.group_by_day(:start_datetime, :range => @date_range_filter_start..@date_range_filter_end).sum(:duration)
                         else
                           @results.group_by_day(:start_datetime).sum(:duration)
                         end
      #@users = [User.find(params[:user])] if params.has_key? :user
      #@dataset = @users.map do |u|
      #  timecards = u.timecards
      #  if params.has_key? :custom_date_range
      #    cdr = params[:custom_date_range].split(",")
      #    timecards = timecards.where("start_datetime BETWEEN ? AND ?",DateTime.parse(cdr[0]),DateTime.parse(cdr[1]))
      #  end
      #  {
      #    :name => u.name,
      #    :data => timecards.map do |tc|
      #      [tc.start_datetime.to_date.to_datetime, tc.duration]
      #    end
      #  }
      #end
      @results = @results.order('start_datetime DESC').all
    end

    def appointments
      @users = User.all
      @users = [User.find(params[:user])] if params.has_key? :user
      @results = Appointment.estimates.all
    end

    def contracts

    end

    def proposals
      @results = Proposal.not_deleted
      @results = @results.where(:sales_person_id => params[:salesperson]) if params.has_key?(:salesperson)
      apply_date_range_filter('proposals.created_at', "@results")
      @proposal_state_distribution = Proposal::STATES.map{|s| [t("proposals.index.states.#{s.downcase}"), @results.where(:proposal_state => s).count]}
      @proposal_template_distribution = ProposalTemplate.all.map do |pt|
        [pt.name, @results.where(:proposal_template_id => pt.id).count]
      end
      @contact_coordinate_data = @results.includes(contact: [:geocoding]).all(joins:{contact:{geocoding:[:geocode]}}).map{|p|p.contact.map_data}.to_json
      @results = @results.all
    end

    def jobs
      @results = Job.in_working_period
      @results = @results.signed_in_time_range(@date_range_filter_start, @date_range_filter_end) if date_range_filter_set?
      @job_state_distribution = Job::STATES.map{|s| [t("jobs.states.#{s.downcase}"), @results.in_state(s).count] }.compact
      @job_lifecycle_averages = Job.average_time_spent_by_state.map{|state, seconds| [t("jobs.states.#{state.downcase}"), seconds] if state!='Completed'}.compact
      @contact_coordinate_data = @results.includes(contact: [:geocoding]).all(joins:{contact:{geocoding:[:geocode]}}).map{|j|j.contact.map_data}.to_json
      @results = @results.all
    end

    def job_cost
      @view = params[:view] || 'totals'

      @years = current_tenant.reporting_years
      @year = (params[:year] || Time.now.year).to_i

      @report = JobCostReport.new(current_tenant, @year)
      @report_data = case params[:view]
                     when 'crew' then @report.dataset_by_crew
                     when 'job' then @report.dataset_by_job
                     else @report.dataset
                     end
    end

    def payroll
      @users = User.joins(:timecards).group('users.id').all
      @results = Timecard.paid
      @results = @results.where(:user_id => params[:user]) if params.has_key? :user
      @payroll_by_employee = @users.map{|u| [u.name, u.total_payout]}
      @payroll_by_job = Job.active.map{|j| [j.full_title, j.total_payout]}
      # @line_chart_data = @results.all() # .map{|tc| [tc.start_datetime.to_date.to_datetime, tc.amount]}
      @line_chart_data = if date_range_filter_set?
                           @results = @results.from_time_range(@date_range_filter_start, @date_range_filter_end)
                           @results.group_by_day(:start_datetime, :range => @date_range_filter_start..@date_range_filter_end).sum(:duration)
                         else
                           @results.group_by_day(:start_datetime).sum(:duration)
                         end
      @results = @results.all
    end

    def expenses
      @expenses = Expense
      @expenses = @expenses.from_time_range(@date_range_filter_start, @date_range_filter_end) if date_range_filter_set?

      @users      = params.has_key?(:user) ? [User.find(params[:user])] : User.all
      @jobs       = params.has_key?(:job) ?  [Job.find(params[:job])]   : Job.active
      @categories = ExpenseCategory.all

      # If there's no explicit user filter, we should also match expenses without a user.
      users_filter = params.has_key?(:user) ? @users : @users + [nil]

      @expenses_by_employee = @expenses.where(job_id: @jobs).breakdown_by_employee(@users)
      @expenses_by_job      = @expenses.where(user_id: users_filter).breakdown_by_job(@jobs)
      @expenses_by_category = @expenses.where(job_id: @jobs).where(user_id: users_filter).breakdown_by_category(@categories)
      @expenses_vs_profit   = @expenses.where(job_id: @jobs).profit_breakdown(@jobs)

      @results = @expenses
      @results = @results.where(job_id: params[:job]) if params.has_key?(:job)
      @results = @results.where(user_id: params[:user]) if params.has_key?(:user)
      @total_expenses = @results.sum(:amount)
      @results = @results.all
    end

    def profit
      @page = params[:page] || 1
      @results = Job.includes(:contact).with_accepted_proposal.uniq

      if params.has_key? :sales_person
        @results = @results.where('jobs.id in (?)', Proposal.where(sales_person_id: params[:sales_person]).pluck(:job_id))
      end

      if params.has_key? :lead_source
        @results = @results.where(lead_source_id: params[:lead_source])
      end

      if params.has_key? :crew
        @results = @results.where(crew_id: params[:crew])
      end
      @results = @results.where("date_of_first_job_schedule_entry BETWEEN ? AND ?", @date_range_filter_start, @date_range_filter_end) if date_range_filter_set?

      if params.has_key? :filter
        @results = @results.active if params[:filter] == 'active'
        @results = @results.completed if params[:filter] == 'completed'
      end

      @results = @results.page(@page).per(20)
    end

    def profit_totals
      @results = Job.with_accepted_proposal.uniq

      if params.has_key? :sales_person
        @results = @results.where('jobs.id in (?)', Proposal.where(sales_person_id: params[:sales_person]).pluck(:job_id))
      end

      if params.has_key? :lead_source
        @results = @results.where(lead_source_id: params[:lead_source])
      end

      if params.has_key? :crew
        @results = @results.where(crew_id: params[:crew])
      end
      @results = @results.where("date_of_first_job_schedule_entry BETWEEN ? AND ?", @date_range_filter_start, @date_range_filter_end) if date_range_filter_set?

      if params.has_key? :filter
        @results = @results.active if params[:filter] == 'active'
        @results = @results.completed if params[:filter] == 'completed'
      end

      job_ids = @results.map(&:id)
      @totals = Job.generate_profit_totals(current_user.organization_id, job_ids)
      render partial: 'profit_totals'
    end

    def deposit_payment_tracking
      @page = params[:page] || 1
      if date_range_filter_set?
        @payments = Payment.where('payments.date_paid BETWEEN ? and ?',@date_range_filter_start, @date_range_filter_end).not_deleted
      else
        @payments = Payment.not_deleted
      end

      @payments = @payments.includes(job: [:contact]).page(@page).per(20)
    end

    def deposit_payment_tracking_totals
      if date_range_filter_set?
        @payments = Payment.where('payments.date_paid BETWEEN ? and ?',@date_range_filter_start, @date_range_filter_end).not_deleted
      else
        @payments = Payment.not_deleted
      end

      @payments = @payments.includes(:job)
      @jobs = @payments.collect{|p| p.job}.uniq

      @total_payments = @payments.reduce(0) do |sum, p|
        sum + p.amount
      end

      @total_estimated = @jobs.reduce(0) do |sum, j|
        sum + j.calculated_amount
      end

      @total_outstanding = @jobs.reduce(0) do |sum, j|
        sum + j.outstanding_balance
      end

      render partial: 'deposit_payment_tracking_totals'
    end

    def sales_performance
      @results = User
      @results = @results.where(:id => params[:user]) if params.has_key? :user
      @results = @results.all

      timerange = date_range_filter_set? ? (@date_range_filter_start..@date_range_filter_end) : false
      @dataset = @results.map do |u|
        output = {
            :name => u.name,
            :appointments_booked => u.appointments_booked(timerange),
            :proposals_created => u.proposals_created(timerange),
            :proposals_accepted => u.proposals_accepted(timerange),
            :jobs_sold => u.jobs_sold_count(timerange),
            :jobs_completed => u.jobs_completed(timerange)
        }
        if output.except(:name).values.sum > 0
          output[:jobs_sold_valuation] = u.jobs_sold_valuation(timerange)
          output[:jobs_completed_valuation] = u.jobs_completed_valuation(timerange)
          output
        end
      end
      @dataset.compact!
    end

    def estimates
      @results = Appointment.estimates.includes(:job => [:contact])
      @results = @results.in_time_range(@date_range_filter_start, @date_range_filter_end) if date_range_filter_set?
      @estimates_by_user = User.all.map{|u| [u.name, @results.where(:user_id => u.id).count]}
      if params.has_key? :user
        @user = User.find(params[:user])
        @results = @results.where(:user_id => params[:user])
      end
      @estimates_by_contact = Contact.not_deleted.map{|c| [c.name, @results.where('jobs.contact_id = ?', c.id).count] }
      @results = @results.all
    end

    def communications
      @results = Communication
      @communication_by_user = User.joins(:communications).group('users.id')
                                   .map{|u| [u.name, @results.where(:user_id => u.id).count]}
      if params.has_key? :user
        @user = User.find(params[:user])
        @results = @results.where(:user_id => params[:user])
      end
      @communication_by_job = Job.active
        .joins(:communications)
        .group('jobs.id')
        .all(:include => [:contact])
        .map{|j| [j.full_title, @results.where(:job_id => j.id).count]}
      @line_chart_data = if date_range_filter_set?
                           @results.group_by_day(:datetime, :range => @date_range_filter_start..@date_range_filter_end).count
                         else
                           @results.group_by_day(:datetime).count
                         end
      @results = @results.from_time_range(@date_range_filter_start, @date_range_filter_end) if date_range_filter_set?
    end

    def accounts_receivable
      @results = User
      @results = @results.where(:id => params[:user]) if params.has_key? :user
      @results = @results.all

      timerange = date_range_filter_set? ? (@date_range_filter_start..@date_range_filter_end) : false

      @jobs = Job.job_scheduled_to_start(timerange)

      if params.has_key?(:sales_person)
        @jobs = @jobs.where('id in (?)',Proposal.where(sales_person_id: params[:sales_person]).pluck(:job_id))
      end

      @jobs = @jobs.order(:date_of_first_job_schedule_entry)

      if params.has_key? :sales_person
        @jobs = @jobs.where('id in (?)',Proposal.where(sales_person_id: params[:sales_person]).pluck(:job_id))
      end

      if params.has_key? :crew
        @jobs = @jobs.where(crew_id: params[:crew])
      end

      @dataset = @results.map do |u|
        output = {
            :name => u.name,
            :appointments_booked => u.appointments_booked(timerange),
            :proposals_created => u.proposals_created(timerange),
            :proposals_accepted => u.proposals_accepted(timerange),
            :jobs_sold => u.jobs_sold_count(timerange),
            :jobs_completed => u.jobs_completed(timerange)
        }
        if output.except(:name).values.sum > 0
          output[:jobs_sold_valuation] = u.jobs_sold_valuation(timerange)
          output[:jobs_completed_valuation] = u.jobs_completed_valuation(timerange)
          output
        end
      end
      @dataset.compact!
    end

    def weekly_booking
      @lead_sources = LeadSource.all
      @results = []

      # proposals with no lead source
      row = {:name => 'No Lead Source '}
      if params[:type] == 'zestimate'
        proposals = Proposal.not_deleted.where('job_id in (?)', Job.where("lead_source_id is NULL").pluck(:id)).joins(:job).joins(:contact).where("contacts.zestimate > 0")
      else
        proposals = Proposal.not_deleted.where('job_id in (?)', Job.where("lead_source_id is NULL").pluck(:id))
      end

      if params.has_key?(:sales_person)
        proposals = proposals.where(sales_person_id: params[:sales_person])
      end

      if date_range_filter_set?
        issued_proposals = proposals.where('proposal_date BETWEEN ? AND ?', @date_range_filter_start, @date_range_filter_end)
        signed_proposals = proposals.signed.where('customer_sig_datetime BETWEEN ? AND ?', @date_range_filter_start, @date_range_filter_end)
      else
        issued_proposals = proposals
        signed_proposals = proposals.signed
      end

      num_issued_proposals = issued_proposals.count
      dollars_proposed = issued_proposals.sum(&:amount)

      num_signed_proposals = signed_proposals.count
      dollars_booked = signed_proposals.sum(&:amount)

      if params[:type] == 'zestimate'
        row[:total_zestimates] = proposals.pluck(:zestimate)
        row[:signed_zestimates] = proposals.signed.pluck(:zestimate)
      end
      row[:all_proposals] = num_issued_proposals
      row[:signed_proposals] = num_signed_proposals
      row[:dollars_proposed] = dollars_proposed
      row[:dollars_booked] = dollars_booked

      if num_issued_proposals == 0
        row[:proposals_percentage] = "0.00%"
      else
        row[:proposals_percentage] = number_to_percentage((num_signed_proposals.to_f/num_issued_proposals)*100, precision:2)
      end

      if dollars_proposed == 0
        row[:dollars_percentage] = "0.00%"
      else
        row[:dollars_percentage] = number_to_percentage((dollars_booked.to_f/dollars_proposed)*100, precision:2)
      end

      if num_issued_proposals == 0
        row[:average_proposal] = 0
      else
        row[:average_proposal] = dollars_proposed.to_f / num_issued_proposals
      end

      if num_signed_proposals == 0
        row[:average_booking] = 0
      else
        row[:average_booking] = dollars_booked.to_f / num_signed_proposals
      end

      @results.push(row)
      # proposals with no lead source

      @lead_sources.each_with_index do |lead_source, index|
        row = {:name => lead_source.name}
        if params[:type] == 'zestimate'
          proposals = Proposal.not_deleted.where('job_id in (?)', Job.where(lead_source_id: lead_source.id).pluck(:id)).joins(:job).joins(:contact).where("contacts.zestimate > 0")
        else
          proposals = Proposal.not_deleted.where('job_id in (?)', Job.where(lead_source_id: lead_source.id).pluck(:id))
        end

        if params.has_key?(:sales_person)
          proposals = proposals.where(sales_person_id: params[:sales_person])
        end

        if date_range_filter_set?
          issued_proposals = proposals.where('proposal_date BETWEEN ? AND ?', @date_range_filter_start, @date_range_filter_end)
          signed_proposals = proposals.signed.where('customer_sig_datetime BETWEEN ? AND ?', @date_range_filter_start, @date_range_filter_end)
        else
          issued_proposals = proposals
          signed_proposals = proposals.signed
        end

        num_issued_proposals = issued_proposals.count
        dollars_proposed = issued_proposals.sum(&:amount)

        num_signed_proposals = signed_proposals.count
        dollars_booked = signed_proposals.sum(&:amount)

        if params[:type] == 'zestimate'
          row[:total_zestimates] = proposals.pluck(:zestimate)
          row[:signed_zestimates] = proposals.signed.pluck(:zestimate)
        end
        row[:all_proposals] = num_issued_proposals
        row[:signed_proposals] = num_signed_proposals
        row[:dollars_proposed] = dollars_proposed
        row[:dollars_booked] = dollars_booked

        if num_issued_proposals == 0
          row[:proposals_percentage] = "0.00%"
        else
          row[:proposals_percentage] = number_to_percentage((num_signed_proposals.to_f/num_issued_proposals)*100, precision:2)
        end

        if dollars_proposed == 0
          row[:dollars_percentage] = "0.00%"
        else
          row[:dollars_percentage] = number_to_percentage((dollars_booked.to_f/dollars_proposed)*100, precision:2)
        end

        if num_issued_proposals == 0
          row[:average_proposal] = 0
        else
          row[:average_proposal] = dollars_proposed.to_f / num_issued_proposals
        end

        if num_signed_proposals == 0
          row[:average_booking] = 0
        else
          row[:average_booking] = dollars_booked.to_f / num_signed_proposals
        end

        @results.push(row)
      end


      @totals = {
        all_proposals: @results.map {|r| r[:all_proposals]}.sum,
        signed_proposals: @results.map {|r| r[:signed_proposals]}.sum,
        dollars_proposed: @results.map {|r| r[:dollars_proposed]}.sum,
        dollars_booked: @results.map {|r| r[:dollars_booked]}.sum
      }

      if @totals[:all_proposals] == 0
        @totals[:proposals_percentage] = "0.00%"
      else
        @totals[:proposals_percentage] = number_to_percentage((@totals[:signed_proposals].to_f/@totals[:all_proposals])*100, precision:2)
      end

      if @totals[:dollars_proposed] == 0
        @totals[:dollars_percentage] = "0.00%"
      else
        @totals[:dollars_percentage] = number_to_percentage((@totals[:dollars_booked].to_f/@totals[:dollars_proposed])*100, precision:2)
      end

      if @totals[:all_proposals] == 0
        @totals[:average_proposal] = 0
      else
        @totals[:average_proposal] = @totals[:dollars_proposed]/@totals[:all_proposals]
      end

      if @totals[:signed_proposals] == 0
        @totals[:average_booking] = 0
      else
        @totals[:average_booking] = @totals[:dollars_booked]/@totals[:signed_proposals]
      end
    end

    def managed_organizations
      @managed_organizations = current_tenant.child_organizations

      selected_organizations = params.has_key?(:ids) ? @managed_organizations.where(id: params[:ids]) : @managed_organizations
      timeframe              = @cdr_value.present? ? (@date_range_filter_start..@date_range_filter_end) : nil
      data                   = selected_organizations.map { |o| [o.name, o.stats(timeframe)] }

      @managed_organizations_data = {
        overview:  Hash[data],
        profit:    data.map { |tup| [tup.first, tup.second[:profit]]    },
        revenue:   data.map { |tup| [tup.first, tup.second[:revenue]]   },
        expenses:  data.map { |tup| [tup.first, tup.second[:expenses]]  },
        job_count: data.map { |tup| [tup.first, tup.second[:job_count]] }
      }
    end

    protected

    def set_per_page
      @results = @results.page(1).per(params[:per_page] ||= 10) unless params.has_key? :per_page and params[:per_page] == "all"
    end
  end
end
