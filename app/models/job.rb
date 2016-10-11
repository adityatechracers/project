# == Schema Information
#
# Table name: jobs
#
#  id                               :integer          not null, primary key
#  title                            :string(255)
#  lead_source_id                   :integer
#  contact_id                       :integer
#  details                          :text
#  probability                      :integer
#  state                            :string(255)
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  start_date                       :datetime
#  end_date                         :datetime
#  email_customer                   :boolean          default(FALSE)
#  crew_id                          :integer
#  organization_id                  :integer
#  estimated_amount                 :decimal(9, 2)    default(0.0)
#  state_change_date                :datetime
#  deleted_at                       :datetime
#  added_by                         :integer
#  crew_wage_rate                   :decimal(9, 2)
#  crew_expense_id                  :integer
#  guid                             :string(255)
#  expected_start_date              :date
#  expected_end_date                :date
#  date_of_first_job_schedule_entry :date
#

include ActionView::Helpers::DateHelper
include ActionView::Helpers::NumberHelper

class Job < ActiveRecord::Base
  attr_accessible :contact_id, :crew_id, :details, :lead_source_id,
    :probability, :state, :title, :start_date, :end_date, :email_customer,
    :communications_attributes, :appointments_attributes, :user_ids,
    :estimated_amount, :organization_id, :added_by, :expected_start_date,
    :expected_end_date
  attr_accessor :job_id

  include QuickBooksConcern::Job

  def self.JOB_FIELDS_EXPORT
    { 'contact_name'=> 'Contact Name',
      'contact_phone' => 'Contact Phone',
      'contact_email'=> 'Contact Email',
      'contact_address'=> 'Contact Address',
      'contact_address2'=> 'Contact Address2',
      'contact_city'=> 'Contact City',
      'contact_region'=> 'Contact Region',
      'contact_zip'=> 'Contact Zip',
      'contact_zestimate'=> 'Zestimate (USD)',
      'contact_company'=> 'Contact Company',
      'lead_source'=> 'Lead Source',
      'status'=> 'Job Status',
      'net_proposal_amount'=> 'Net Proposal Amount',
      'new_budgeted_hours'=> 'Net Budgeted Hours',
      'total_expenses'=> 'Total Expenses',
      'total_payment'=> 'Total Payment',
      'expected_start_date'=> 'Expected Start Date',
      'expected_end_date'=> 'Expected End Date',
      'deleted' => 'Deleted At'}
  end

  def self.job_export(organization_id)
    sql = """
      SELECT TRIM(c.first_name) || ' ' || TRIM(c.last_name) AS contact_name, c.phone, c.email,
      c.address, c.address2, c.city, c.region, c.zip, c.zestimate, c.company, ls.name AS lead_source,
      CASE WHEN j.state = 'Proposed' THEN 'Unscheduled' ELSE j.state END as status,
      SUM(Case when p.proposal_state = 'Accepted' THEN co.proposal_amount_change ELSE 0 END) + SUM(case when p.proposal_state = 'Accepted' THEN p.amount else 0 END) AS net_proposal_amount,
      SUM(Case when p.proposal_state = 'Accepted' THEN co.budgeted_hours_change ELSE 0 END) + SUM(case when p.proposal_state = 'Accepted' THEN p.budgeted_hours else 0 END) AS net_budgeted_hours,
      COALESCE(SUM(e.amount),0) as total_expenses, COALESCE(SUM(pa.amount),0) AS total_payments,
      j.expected_start_date, j.expected_end_date,
      CASE WHEN j.deleted_at IS NOT NULL THEN j.deleted_at ELSE NULL END AS deleted
      FROM jobs AS j
      LEFT JOIN proposals AS p ON j.id = p.job_id
      INNER JOIN contacts AS c ON c.id = j.contact_id
      LEFT JOIN lead_sources AS ls ON ls.id = j.lead_source_id
      LEFT JOIN change_orders AS co on co.proposal_id = p.id
      LEFT JOIN expenses AS e ON e.job_id = j.id
      LEFT JOIN payments AS pa ON pa.job_id = j.id
      WHERE j.organization_id = #{organization_id} AND j.state != 'Lead'
      GROUP BY j.id, co.id, c.id, ls.id
      ORDER BY j.deleted_at DESC;
      """

    results = ActiveRecord::Base.connection.execute(sql)
  end

  def self.LEAD_FIELDS_EXPORT
    {'first_name' => 'First Name',
     'last_name' => 'Last Name',
     'phone' => 'Phone',
     'email' => 'Email',
     'address' => 'Address',
     'address2' => 'Address 2',
     'city' => 'City',
     'region' => 'State',
     'zip' => 'Zip',
     'zestimate' => 'Zestimate (USD)',
     'company' => 'Company',
     'lead_source' => 'Lead Source',
     'dead' => 'Dead',
     'deleted' => 'Deleted At'}
  end

  def self.lead_export(organization_id)
    sql = """
      SELECT TRIM(c.first_name) AS first_name, TRIM(c.last_name) AS last_name, c.phone, c.email,
      c.address, c.address2, c.city, c.region, c.zip, c.zestimate, c.company, ls.name, j.dead,
      CASE WHEN j.deleted_at IS NOT NULL THEN j.deleted_at ELSE NULL END AS deleted
      FROM jobs AS j
      INNER JOIN contacts AS c ON c.id = j.contact_id
      LEFT JOIN lead_sources AS ls ON ls.id = j.lead_source_id
      WHERE j.organization_id = #{organization_id} AND j.state = 'Lead'
      ORDER BY j.deleted_at DESC;
      """
    results = ActiveRecord::Base.connection.execute(sql)
  end

  def self.generate_profit_totals(organization_id, ids)

    ids = [-1] if ids.empty?

    estimated_amount_sql = """
      SELECT SUM(p.amount)
      FROM jobs AS j
      INNER JOIN proposals AS p ON p.job_id = j.id
      WHERE j.organization_id = #{organization_id}
      AND j.id IN (#{ids.join(",")})
      AND p.proposal_state = 'Accepted'
      AND j.deleted_at IS NULL
      AND p.deleted_at IS NULL
    """

    estimated_amount = ActiveRecord::Base.connection.execute(estimated_amount_sql).first['sum'].to_f

    total_payments_sql = """
      SELECT SUM(p.amount)
      FROM payments AS p
      WHERE p.organization_id = #{organization_id} AND p.job_id IN (#{ids.join(",")})
      AND p.deleted_at IS NULL
    """

    total_payments = ActiveRecord::Base.connection.execute(total_payments_sql).first['sum'].to_f

    expected_payout_sql = """
      SELECT SUM(e.amount) FROM expenses AS e
      Where e.expense_category_id IN (SELECT id FROM expense_categories
                                      WHERE name = 'Labor'
                                      AND organization_id = #{organization_id})
      AND e.deleted_at IS NULL
      AND e.job_id IN (#{ids.join(',')})
    """

    total_timecards_sql = """
      SELECT SUM(t.amount) FROM timecards AS t
      Where t.organization_id = #{organization_id}
      AND t.deleted_at IS NULL
      AND t.job_id IN (#{ids.join(',')})
    """
    expected_payout = ActiveRecord::Base.connection.execute(expected_payout_sql).first['sum'].to_f + ActiveRecord::Base.connection.execute(total_timecards_sql).first['sum'].to_f

    total_expenses_sql = """
      SELECT SUM(e.amount) FROM expenses AS e
      Where (e.expense_category_id NOT IN (SELECT id FROM expense_categories
                                      WHERE name = 'Labor'
                                      AND organization_id = #{organization_id})
             OR e.expense_category_id IS NULL)
      AND e.deleted_at IS NULL
      AND e.job_id IN (#{ids.join(',')})
    """

    total_expenses = ActiveRecord::Base.connection.execute(total_expenses_sql).first['sum'].to_f

    expected_profit = estimated_amount - expected_payout - total_expenses

    {
      estimated_amount: estimated_amount,
      payout: expected_payout,
      expenses: total_expenses,
      payments: total_payments,
      profit: expected_profit
    }
  end

  scope :from_time_range, lambda { |s, e| where('jobs.created_at BETWEEN ? AND ?',s,e).order('jobs.created_at ASC') }
  scope :active, not_deleted
  scope :active_leads, not_deleted.where(state: "Lead", dead: false)
  scope :dead_leads, not_deleted.where(state: "Lead", dead: true)
  scope :active_or_dead, where("deleted_at IS NOT NULL AND state = ? OR deleted_at IS NULL", "Lead")
  scope :leads, where(:state => "Lead")
  scope :leads_today, lambda {
    active_leads.joins(:communications)
      .where('communications.datetime BETWEEN ? AND ?', Time.zone.now, Time.zone.now.end_of_day)
      .order("communications.datetime ASC") }
  scope :leads_next_year, lambda {
    active_leads.joins(:communications)
      .where('communications.datetime >= ?', 1.year.from_now)
      .order("communications.id ASC") }
  scope :leads_from_time_range, lambda { |s, e|
    active_leads
      .joins('LEFT OUTER JOIN communications ON jobs.id = communications.job_id')
      .where('(jobs.created_at BETWEEN :start AND :end) OR (communications.datetime BETWEEN :start AND :end)', start: s, end: e)
  }
  scope :job_from_time_range, lambda { |s, e|
    active
      .where('jobs.created_at BETWEEN :start AND :end', start: s, end: e)
  }
  scope :unscheduled, not_deleted.where(:state => 'Accepted')
  scope :scheduled, not_deleted.where(:state => 'Scheduled')
  scope :completed, not_deleted.where(:state => "Completed")
  scope :not_completed, not_deleted.where('state != ?',"Completed")
  scope :in_state, lambda{|mState| not_deleted.where('state = ?', mState) }
  scope :transcended, not_deleted.where('state != ?', 'Lead')
  scope :in_working_period, not_deleted.where('state = ? OR state = ?', 'Accepted', 'Scheduled')
  scope :with_accepted_proposal, not_deleted.joins(:proposals).where('proposals.deleted_at IS NULL and proposals.proposal_state = ?', 'Accepted')
  scope :signed_in_time_range, lambda{|s, e|
    with_accepted_proposal
      .select('DISTINCT jobs.id, jobs.*, GREATEST(DATE(proposals.customer_sig_datetime), DATE(proposals.contractor_sig_datetime)) AS signed_at')
      .where('GREATEST(DATE(proposals.customer_sig_datetime), DATE(proposals.contractor_sig_datetime)) BETWEEN ? AND ?', s, e)
      .order('signed_at ASC') }
  scope :with_outstanding_balance, lambda{
    with_accepted_proposal
      .includes(:payments)
      .select('jobs.id')
      .select('((CASE WHEN COUNT(proposals.id) > 0 THEN SUM(proposals.amount) ELSE 0.00 END) - ' +
               '(CASE WHEN COUNT(payments.id) > 0 THEN SUM(payments.amount) ELSE 0.00 END)) AS outstanding_balance')
      .group('jobs.id, payments.id')
      .having('((CASE WHEN COUNT(proposals.id) > 0 THEN SUM(proposals.amount) ELSE 0.00 END) - ' +
               '(CASE WHEN COUNT(payments.id) > 0 THEN SUM(payments.amount) ELSE 0.00 END)) > 0')
      .order('((CASE WHEN COUNT(proposals.id) > 0 THEN SUM(proposals.amount) ELSE 0.00 END) - ' +
              '(CASE WHEN COUNT(payments.id) > 0 THEN SUM(payments.amount) ELSE 0.00 END)) DESC') }
  scope :starting_during, lambda{|range|
    joins(:job_schedule_entries).where('jobs.id in (
        SELECT job_schedule_entries.job_id
        WHERE job_schedule_entries.id = (
          SELECT job_schedule_entries.id FROM job_schedule_entries, jobs
          WHERE job_schedule_entries.job_id = jobs.id
          ORDER BY job_schedule_entries.start_datetime asc
          LIMIT 1
        )
        AND job_schedule_entries.start_datetime BETWEEN :start AND :end
      )', start: range.begin, end: range.end + 1.day).uniq
  }

  belongs_to :contact
  belongs_to :lead_source
  belongs_to :crew
  belongs_to :creator, :class_name => "User", :foreign_key => "added_by"
  has_many :communications, :inverse_of => :job, dependent: :destroy
  has_many :communication_records, :order => "datetime DESC", :class_name => "Communication", :conditions => {:type => "CommunicationRecord"}
  has_many :planned_communications, :order => "datetime ASC", :class_name => "Communication", :conditions => {:type => "PlannedCommunication"}
  has_one :next_communication, :class_name => "Communication", :conditions => proc { "communications.type = 'PlannedCommunication' AND communications.datetime >= '#{Time.zone.now}'" }, :order => "communications.datetime ASC"
  has_one :last_communication, :class_name => "Communication", :conditions => {:type => 'CommunicationRecord'}, :order => "datetime DESC"
  has_many :job_users
  has_many :users, :through => :job_users
  has_many :appointments, dependent: :destroy
  has_one :next_appointment, :class_name => "Appointment", :conditions => proc { "start_datetime >= '#{Time.zone.now}' AND appointments.deleted_at IS NULL" }, :order => "start_datetime ASC"
  has_many :proposals, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :timecards, dependent: :destroy
  has_many :activities, :as => :loggable
  has_many :job_schedule_entries, dependent: :destroy
  has_many :job_feedbacks, dependent: :destroy

  accepts_nested_attributes_for :communications
  accepts_nested_attributes_for :appointments
  accepts_nested_attributes_for :job_schedule_entries

  acts_as_tenant :organization

  before_create :set_guid
  before_save :set_state, :update_crew_fields
  after_create :send_welcome_email

  STATES = ["Lead", "Proposed", "Accepted", "Scheduled", "Completed"]

  def crews
    job_schedule_entries.sent.includes(:crew).map(&:crew).compact.uniq
  end

  def send_invoice amount, description
    proposal.try do |target|
      target.qb_create_progress_payment_invoice amount, description
    end
  end
  def status
    state
  end
  class << self
    def send_appointment_2_day_follow_ups
      leads.where("date(created_at) = ?", Time.zone.now.to_date - 2.days).each do |j|
        ActsAsTenant.with_tenant(j.organization) do
          JobsMailer.appointment_2_day_follow_up(j).deliver if j.appointments.empty?
        end
      end
    end

    def send_appointment_7_day_follow_ups
      leads.where("date(created_at) = ?", Time.zone.now.to_date - 7.days).each do |j|
        ActsAsTenant.with_tenant(j.organization) do
          JobsMailer.appointment_7_day_follow_up(j).deliver if j.appointments.empty?
        end
      end
    end

    def send_job_complete_1_month_follow_ups
      completed.where('date(state_change_date) = ?', Time.zone.now.to_date - 1.month).each do |j|
        ActsAsTenant.with_tenant(j.organization) do
          JobsMailer.job_complete_1_month_follow_up(j).deliver
        end
      end
    end

    def unscheduled_as_calendar_events
      unscheduled.all
        .select { |job| job.expected_start_date(true).present? && job.expected_end_date(true).present? }
        .map do |job|
          {
            allDay: false,
            className: 'unscheduled-job',
            title: job.event_title,
            start: job.expected_start_date(true),
            end: job.expected_end_date(true) + 1.day,
            unscheduled: true,
            jobId: job.id
          }
        end
    end
  end

  def proposal
    proposals.order("created_at DESC").first
  end
  def has_next_communication?
    self.next_communication.present?
  end

  def next_communication_indicator_cell(nc=nil)
    nc ||= self.next_communication
    return "<td class='indicator-cell'>N/A</td>" if nc.blank?
    ncd = nc.datetime
    labeltype = ncd < Time.zone.now.end_of_day.to_datetime ? 'important' : (ncd < 7.days.since(Time.zone.now).to_datetime ? 'warning' : 'success')
    labelday = if ncd.to_date.today? then "Today" else if ncd.to_date == Date.tomorrow then "Tomorrow" else "%A, %B %e"+(ncd.year!=Time.zone.now.year ? ", %Y":"") end end
    st = ncd.strftime(labelday+" #{self.next_communication.datetime_exact ? "at" : "around"} %l:%M%p")
    rt = distance_of_time_in_words_to_now(ncd)+" from now"
    output = "<td class='indicator-cell indicator-cell-#{labeltype}'>"
    output += "<span class='next-contact-indicator' data-toggle='tooltip' title='#{rt}'>#{st}</span>"
    output += "<i class='icon-clock pull-right' data-toggle='tooltip' data-title='This time is exact' />" if nc.datetime_exact
    output += "</td>"
    output
  end

  def next_appointment_indicator_cell(na=nil)
    na ||= self.next_appointment
    return "<td class='indicator-cell footable'></td>" if na.nil?
    nd = na.start_datetime
    labeltype = nd < 1.days.since(Time.zone.now).to_datetime ? "important" : (nd < 7.days.since(Time.zone.now).to_datetime ? "warning" : "success")
    labelday = if nd.to_date.today? then "Today" else if nd.to_date == Date.tomorrow then "Tomorrow" else "%A, %B %e"+(nd.year!=Time.zone.now.year ? ", %Y":"") end end
    st = nd.strftime(labelday+" at %l:%M%p")
    rt = distance_of_time_in_words_to_now(nd)+" from now"
    "<td class='indicator-cell indicator-cell-#{labeltype} footable'><span class='next-appointment-indicator' data-toggle='tooltip' title='#{rt}'>#{st}</span></td>"
  end

  def set_guid
    self.guid = SecureRandom.uuid
  end

  ACTIVITY_EVENT_TYPE = "job.state_change"
  def set_state
    # Set some defaults
    self.title ||= "Untitled Job"

    # Determine new state
    unless (from_state = self.state) == "Completed"
      self.state = if !self.has_proposal?
        "Lead"
      elsif !self.has_signed_proposal?
        "Proposed"
      elsif !self.is_scheduled?
        "Accepted"
      else
        "Scheduled"
      end
    end

    # Log state change activity
    unless self.last_sca_state == self.state
      Activity.create({
        :event_type => ACTIVITY_EVENT_TYPE,
        :data => {:to => self.state, :from => from_state},
        :loggable_id => self.id,
        :loggable_type => "Job"
      })
      self.state_change_date = Time.zone.now.to_date
    end
  end

  def state_change_activities(state=nil)
    sca = self.activities.where({:event_type => ACTIVITY_EVENT_TYPE}).order("created_at ASC")
    sca = sca.map {|a| a if a.data[:to]==state} unless state.nil?
    sca
  end

  def has_activity?(conditions={})
    a = self.activities
    a = a.where(conditions) if conditions.any?
    a.any?
  end

  def has_state_change_activity?(state=nil)
    self.state_change_activities(state).any?
  end

  def last_activity(conditions={})
    a = self.activities.order("created_at ASC")
    a = a.where(conditions) if conditions.any?
    return false unless a.any?
    a.last
  end

  def last_state_change_activity(state=nil)
    sca = self.state_change_activities(state)
    return false unless sca.any?
    sca.last
  end

  def last_sca_state
    last = last_state_change_activity
    return false if !last
    last.data[:to]
  end

  # def time_spent_by_state
#     time_spent = Hash[STATES.map {|x| [x, 0]}]
#     last_state = false
#     self.state_change_activities.each do |sca|
#       this_state = sca.data[:from] || STATES[0]
#       time_spent[this_state] += if last_state==false
#         sca.created_at - self.created_at
#       elsif this_state==last_sca_state
#         Time.zone.now - sca.created_at
#       else
#         sca.created_at - last_state.created_at
#       end
#       last_state = sca
#     end
#     time_spent
#   end

  def time_spent_by_state
    time_spent = Hash[STATES.map {|x| [x, 0]}]
    sca_all = self.state_change_activities
    sca_all.each_with_index do |sca,index|
      next_state = sca_all[index+1]||false
      time_spent[sca.data[:to]] += if next_state==false
        Time.zone.now - sca.created_at
      else
        next_state.created_at - sca.created_at
      end
    end
    time_spent
  end

  def self.average_time_spent_by_state
    totals = Hash[STATES.map {|x| [x, 0]}]
    counts = totals.dup
    averages = totals.dup
    not_deleted.each do |j|
      j.time_spent_by_state.each do |state,seconds|
        totals[state] += seconds
        counts[state] += 1
      end
    end
    totals.each {|state,total| averages[state] = (total.to_f/counts[state].to_f).round(1)}
    averages
  end

  def self.average_percentage_time_spent_by_state
    percentages = Hash[STATES.map {|x| [x, 0]}]
    averages = self.average_time_spent_by_state
    total_seconds = 0
    averages.each {|state,average| total_seconds += average}
    averages.each {|state,average| percentages[state] = (average.to_f/total_seconds.to_f).round(3)*100}
    percentages
  end

  def self.job_scheduled_to_start(time_range=false)
    if time_range
      active.where('jobs.date_of_first_job_schedule_entry >= ? AND jobs.date_of_first_job_schedule_entry <= ?', time_range.first, time_range.last)
    else
      active
    end
  end

  def has_proposal?
    self.proposals.not_deleted.any?
  end

  def has_signed_proposal?
    self.proposals.signed.any?
  end

  def is_scheduled?
    job_schedule_entries.any?
  end

  def default_expected_start_date
    proposals.accepted
      .where('expected_start_date IS NOT NULL')
      .order('expected_start_date ASC')
      .first
      .try(:expected_start_date)
  end

  def default_expected_end_date
    proposals.accepted
      .where('expected_end_date IS NOT NULL')
      .order('expected_end_date DESC')
      .first
      .try(:expected_end_date)
  end

  def expected_start_date(default_from_proposals = false)
    val = read_attribute(:expected_start_date)
    return default_expected_start_date if val.nil? && default_from_proposals
    val
  end

  def expected_end_date(default_from_proposals = false)
    val = read_attribute(:expected_end_date)
    return default_expected_end_date if val.nil? && default_from_proposals
    val
  end

  def contact_name
    if self.contact.present? and self.contact.backwards_name.present?
      o = self.contact.backwards_name
    else
      o = 'Unknown'
    end
    o
  end

  def contact_id
    if self.contact.present? and self.contact.backwards_name.present?
      o = self.contact.id
    else
      o = 0
    end
    o
  end


  def full_title
    if self.contact.present? and self.contact.backwards_name.present?
      o = self.contact.backwards_name
      o += " - #{self.title}" if self.title.present?
    elsif self.title.present?
      o = self.title
    end
    o
  end

   def full_title_with_address
    if self.contact.present? and self.contact.backwards_name.present?
      o = self.contact.backwards_name
      o += " - #{self.contact.address} #{self.contact.city}" if self.contact.address.present? and self.contact.city.present?
    elsif self.title.present?
      o = self.title
    end
    o
  end

  def minimzed_full_title
    if self.contact.present? and self.contact.backwards_name.present?
      o = self.contact.backwards_name
    elsif self.title.present?
      o = self.title
    end
    o
  end

  def event_title
    %{ #{full_title} (#{calculated_hours.to_i}/#{budgeted_hours} budgeted hours)
       #{contact.condensed_address}
       #{contact.phone}}
  end

  def title
    read_attribute(:title) || "##{id}"
  end

  def is_completed?
    self.state == "Completed"
  end

  def is_dead?
    self.dead?
  end

  def has_crew?
    self.crew.present?
  end

  def most_recent_proposal_id
    proposals.not_deleted.order("created_at desc").first.try(:id)
  end
  def calculated_amount
    self.proposals.not_deleted.sum(:amount)
  end

  def approved_proposals_amount
    self.proposals.not_deleted.accepted.sum(:amount)
  end


  def calculated_hours
    self.timecards.not_deleted.sum(:duration)
  end

  def total_expenses
    labor_ids = ExpenseCategory.where(name: 'Labor').pluck(:id)
    expenses.where('expense_category_id not in (?) or expense_category_id is null', labor_ids).not_deleted.sum(:amount)
  end

  def total_payout
    timecards.not_deleted.paid.sum(:amount)
  end

  def expected_payout
    labor_ids = ExpenseCategory.where(name: 'Labor').pluck(:id)
    expenses.where('expense_category_id in (?)',labor_ids).not_deleted.sum(:amount)
  end

  def total_payments
    payments.not_deleted.sum(:amount)
  end

  def profit
    total_payments - total_payout - total_expenses
  end

  def expected_profit
    approved_proposals_amount - expected_payout - total_expenses
  end

  def expected_profit_profit_report timecard_expense
    approved_proposals_amount - (expected_payout+timecard_expense) - total_expenses
  end

  def budgeted_hours
    return 0 unless has_proposal?
    proposals.not_deleted.sum(:budgeted_hours)
  end

  def overbudget?
    self.calculated_hours > self.budgeted_hours
  end

  def has_outstanding_balance?
    outstanding_balance > 0
  end

  def estimated_outstanding_balance
    return 0.0 unless approved_proposals_amount > 0.0
    approved_proposals_amount - total_payments
  end

  def outstanding_balance
    return 0.0 unless has_signed_proposal?
    calculated_amount - total_payments
  end

  def full_title_with_address_and_phone
    "#{self.full_title} @ #{self.contact.condensed_address} | #{self.contact.phone}"
  end

  def minimzed_full_title_with_address
    "#{self.minimzed_full_title} - #{self.contact.minimized_condensed_address}"
  end

  def title_only
    "#{self.contact.backwards_name} - #{self.contact.address}, #{self.contact.city}"
  end

  def name_address_proposal_number
    if self.proposals.length > 0
      "#{self.contact.name} - ##{self.proposals.first.proposal_number} #{self.contact.address}"
    else
      "#{self.contact.name} | #{self.contact.address}"
    end
  end

  def source_name
    self.lead_source.nil? ? "Unknown Source" : self.lead_source.name
  end

  private

  def send_welcome_email
    JobsMailer.lead_welcome(self).deliver if self.email_customer
  end

  def update_crew_fields
    set_crew_wage_rate if crew_id_changed?
    update_crew_expense
  end

  def set_crew_wage_rate
    if crew_id.present? && organization.uses_crew_commissions
      self.crew_wage_rate = crew.wage_rate
    else
      self.crew_wage_rate = nil
    end
  end

  def update_crew_expense
    if crew_wage_rate.present?
      expense = Expense.find_by_id(crew_expense_id) || Expense.new
      expense.set_crew_labor_attributes(self)
      expense.save!
      self.crew_expense_id = expense.id
    else
      Expense.where(id: crew_expense_id).delete_all
    end
  end

end
