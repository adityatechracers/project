class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:google_oauth2]
  mount_uploader :image, ProfileImageUploader
  crop_uploaded :image

  # Setup accessible (or protected) attributes for your model
  attr_protected :id
  attr_accessor :organization_name, :terms_of_service

  module Language
    ENGLISH = 'en'
    FRENCH_CANADA = 'fr-CA'

    def self.collection
      [['English', ENGLISH], ['French (Canada)', FRENCH_CANADA]]
    end
  end

  PERMISSION_FLAGS = [
    :can_be_assigned_appointments,
    :can_be_assigned_jobs,
    :can_make_timecards,
    :can_manage_all_contacts,
    :can_manage_appointments,
    :can_manage_jobs,
    :can_manage_leads,
    :can_manage_proposals,
    :can_view_all_contacts,
    :can_view_all_jobs,
    :can_view_all_proposals,
    :can_view_appointments,
    :can_view_assigned_proposals,
    :can_view_leads,
    :can_view_own_jobs
  ]

  APPOINTMENTS_COLORS = [
    '#809FFF', '#9F80FF', '#DF80FF', '#FF80DF',
    '#FF809F', '#FF9F80', '#FFDF80', '#DFFF80',
    '#9FFF80', '#80FF9F', '#80FFDF', '#80DFFF',
    '#4271FF', '#0544FF', '#FFD042', '#FFC105'
  ]


  scope :employees, where(:role => "Employee")
  scope :top_calls_this_year, lambda {
    joins(:communications)
      .where("communications.deleted_at IS NULL AND communications.type = ? AND communications.datetime BETWEEN ? AND ?", "CommunicationRecord", Time.now.beginning_of_year, Time.now.end_of_week)
      .select('users.*, COUNT(DISTINCT(communications.id)) as comm_count')
      .group('users.id')
      .order("comm_count DESC")
      .limit(5)
  }
  scope :top_leads_this_year, lambda {
    joins(:created_leads)
      .where("jobs.deleted_at IS NULL AND jobs.created_at BETWEEN ? AND ?", Time.now.beginning_of_year, Time.now.end_of_week)
      .select('users.*, COUNT(DISTINCT(jobs.id)) as job_count')
      .group('users.id')
      .order("job_count DESC")
      .limit(5)
  }
  scope :top_proposals_this_year, lambda {
    joins(:created_proposals)
      .where("proposals.deleted_at IS NULL AND proposals.created_at BETWEEN ? AND ?", Time.now.beginning_of_year, Time.now.end_of_week)
      .select("users.*, COUNT(DISTINCT(proposals.id)) as proposal_count")
      .group('users.id')
      .order("proposal_count DESC")
      .limit(5)
  }
  scope :top_jobs_this_year, lambda {
    joins(:proposal_sales)
      .where('proposals.deleted_at IS NULL AND (proposals.customer_sig_printed_name IS NOT NULL AND proposals.contractor_sig_printed_name IS NOT NULL) AND ((GREATEST(DATE(proposals.customer_sig_datetime), DATE(proposals.contractor_sig_datetime))) BETWEEN ? AND ?)', Time.now.beginning_of_year, Time.now.end_of_week)
      .select("users.*, COUNT(DISTINCT(proposals.id)) as job_count")
      .group('users.id')
      .order("job_count DESC")
      .limit(5)
  }
  scope :top_estimates_this_year, lambda {
    joins(:appointments)
      .where("appointments.deleted_at IS NULL AND appointments.job_id IS NOT NULL AND (appointments.created_at BETWEEN ? AND ?)", Time.now.beginning_of_year, Time.now.end_of_week)
      .select("users.*, COUNT(DISTINCT(appointments.id)) as appointment_count")
      .group('users.id')
      .order("appointment_count DESC")
      .limit(5)
  }

  scope :top_calls_this_week, lambda {
    joins(:communications)
      .where("communications.deleted_at IS NULL AND communications.type = ? AND communications.datetime BETWEEN ? AND ?", "CommunicationRecord", Time.now.beginning_of_week, Time.now.end_of_week)
      .select('users.*, COUNT(DISTINCT(communications.id)) as comm_count')
      .group('users.id')
      .order("comm_count DESC")
      .limit(5)
  }
  scope :top_leads_this_week, lambda {
    joins(:created_leads)
      .where("jobs.deleted_at IS NULL AND jobs.created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week)
      .select('users.*, COUNT(DISTINCT(jobs.id)) as job_count')
      .group('users.id')
      .order("job_count DESC")
      .limit(5)
  }
  scope :top_proposals_this_week, lambda {
    joins(:created_proposals)
      .where("proposals.deleted_at IS NULL AND proposals.created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week)
      .select("users.*, COUNT(DISTINCT(proposals.id)) as proposal_count")
      .group('users.id')
      .order("proposal_count DESC")
      .limit(5)
  }
  scope :top_jobs_this_week, lambda {
    joins(:proposal_sales)
      .where('proposals.deleted_at IS NULL AND (proposals.customer_sig_printed_name IS NOT NULL AND proposals.contractor_sig_printed_name IS NOT NULL) AND ((GREATEST(DATE(proposals.customer_sig_datetime), DATE(proposals.contractor_sig_datetime))) BETWEEN ? AND ?)', Time.now.beginning_of_week, Time.now.end_of_week)
      .select("users.*, COUNT(DISTINCT(proposals.id)) as job_count")
      .group('users.id')
      .order("job_count DESC")
      .limit(5)
  }
  scope :top_estimates_this_week, lambda {
    joins(:appointments)
      .where("appointments.deleted_at IS NULL AND appointments.job_id IS NOT NULL AND (appointments.created_at BETWEEN ? AND ?)", Time.now.beginning_of_week, Time.now.end_of_week)
      .select("users.*, COUNT(DISTINCT(appointments.id)) as appointment_count")
      .group('users.id')
      .order("appointment_count DESC")
      .limit(5)
  }

  scope :active_users, where(active: true)

  def self.by_availability(date)
    sql = <<-SQL
      SELECT COUNT(a.id) + COUNT(g.id), u.*
      FROM appointments a RIGHT JOIN users u ON a.user_id = u.id AND DATE(a.start_datetime) = '#{date}' AND a.deleted_at IS NULL
      LEFT JOIN google_events g ON u.id = g.user_id AND DATE(g.start_datetime) = '#{date}' AND g.status <> 'canceled'
      GROUP BY u.id
      ORDER BY COUNT(a.id) + COUNT(g.id) ASC;
    SQL

    results = ActiveRecord::Base.connection.execute(sql)
  end

  validates :terms_of_service, :acceptance => true
  validates :role, :owner => true
  validates :first_name, :last_name, :email, presence: true

  belongs_to :organization
  acts_as_tenant :organization
  has_many :job_users
  has_many :jobs, :through => :job_users
  has_many :created_proposals, :class_name => "Proposal", :foreign_key => "added_by"
  has_many :proposal_sales, :class_name => "Proposal", :foreign_key => "sales_person_id", :conditions => {:proposal_state => 'Accepted'}
  has_and_belongs_to_many :crews
  has_many :communications
  has_many :appointments
  has_many :timecards
  has_many :created_leads, :class_name => "Job", :foreign_key => "added_by"
  has_many :expenses
  has_many :job_sales, :class_name => "Job", :through => :proposal_sales, :source => :job
  has_many :google_events
  has_many :google_calendars


  paginates_per 15

  before_create :create_organization, :capitalize_names
  before_save :check_organization_user_count
  before_save :check_permissions
  before_save :set_appointments_color, :if => Proc.new {|object| object.appointments_color.nil?}
  after_create :send_welcome_email
  after_update :update_stripe_email

  include UserAdmin

  def set_appointments_color
    available = APPOINTMENTS_COLORS - User.all.map(&:appointments_color)
    return self.appointments_color = APPOINTMENTS_COLORS[0] if available.empty?
    self.appointments_color = available.sample
  end

  def active_for_authentication?
    super && self.active && (self.is_admin? || self.can_manage? || self.organization.active)
  end

  def is_employee?
    role == 'Employee'
  end

  def is_manager?
    role == 'Manager'
  end

  def is_owner?
    role == 'Owner'
  end

  def is_admin?
    role == 'Admin'
  end

  def can_manage?
    role.in? ['Owner', 'Manager']
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def backwards_name
    return (self.first_name || self.last_name).to_s unless self.first_name.present? && self.last_name.present?
    "#{self.last_name}, #{self.first_name}"
  end

  def full_address
    components = [self.address, self.address2, self.city, self.region, self.zip]
    components.each_with_index {|c,i| components.delete(c) if c.blank? }
    components.join(", ")
  end

  def condensed_address
    components = [self.address, self.city]
    components.each_with_index {|c,i| components.delete(c) if c.blank? }
    components.join(", ")
  end

  def has_address?
    self.address.present? && self.city.present? && self.region.present?
  end

  def leads_called_this_week
    self.communications.records.where("datetime BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
  end
  def leads_called_this_week_percentage
    org_calls = CommunicationRecord.where("datetime BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
    org_calls = 1 if org_calls == 0
    ((leads_called_this_week.to_f / org_calls.to_f) * 100).round
  end

  def leads_called_last_week
    self.communications.records.where("datetime BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
  end
  def leads_called_last_week_percentage
    org_calls = CommunicationRecord.where("datetime BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
    org_calls = 1 if org_calls == 0
    ((leads_called_last_week.to_f / org_calls.to_f) * 100).round
  end

  def leads_called_on_average
    (self.communications.records.count / weeks_active).round
  end
  def leads_called_on_average_percentage
    org_calls = (CommunicationRecord.count / organization.weeks_active).round
    org_calls = 1 if org_calls == 0
    ((leads_called_on_average.to_f / org_calls.to_f) * 100).round
  end

  def estimates_scheduled_this_week
    self.appointments.estimates.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
  end
  def estimates_scheduled_this_week_percentage
    org_estimates = Appointment.estimates.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
    org_estimates = 1 if org_estimates == 0
    ((estimates_scheduled_this_week.to_f / org_estimates.to_f) * 100).round
  end

  def estimates_scheduled_last_week
    self.appointments.estimates.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
  end
  def estimates_scheduled_last_week_percentage
    org_estimates = Appointment.estimates.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
    org_estimates = 1 if org_estimates == 0
    ((estimates_scheduled_last_week.to_f / org_estimates.to_f) * 100).round
  end

  def estimates_scheduled_on_average
    (self.appointments.estimates.count / weeks_active).round
  end
  def estimates_scheduled_on_average_percentage
    org_estimates = (Appointment.estimates.count / organization.weeks_active).round
    org_estimates = 1 if org_estimates == 0
    ((estimates_scheduled_on_average.to_f / org_estimates.to_f) * 100).round
  end

  def leads_added_this_week
    self.created_leads.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
  end
  def leads_added_this_week_percentage
    org_leads = Job.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
    org_leads = 1 if org_leads == 0
    ((leads_added_this_week.to_f / org_leads.to_f) * 100).round
  end
  def leads_added_ytd
    self.created_leads.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_year, Time.now.end_of_week).count
  end
  def leads_added_last_week
    self.created_leads.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
  end
  def leads_added_last_week_percentage
    org_leads = Job.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
    org_leads = 1 if org_leads == 0
    ((leads_added_last_week.to_f / org_leads.to_f) * 100).round
  end

  def leads_added_on_average
    (self.created_leads.count / weeks_active).round
  end
  def leads_added_on_average_percentage
    org_leads = (Job.count / organization.weeks_active).round
    org_leads = 1 if org_leads == 0
    ((leads_added_on_average.to_f / org_leads.to_f) * 100).round
  end
  def proposals_added(time_range=false)
    self.created_proposals.where("created_at BETWEEN ? AND ?", time_range.first, time_range.last).count
  end
  def proposals_added_this_week
    self.created_proposals.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
  end
  def proposals_added_this_week_percentage
    org_proposals = Proposal.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
    org_proposals = 1 if org_proposals == 0
    ((proposals_added_this_week.to_f / org_proposals.to_f) * 100).round
  end

  def proposals_added_last_week
    self.created_proposals.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
  end
  def proposals_added_last_week_percentage
    org_proposals = Proposal.where("created_at BETWEEN ? AND ?", Time.now.beginning_of_week, Time.now.end_of_week).count
    org_proposals = 1 if org_proposals == 0
    ((proposals_added_last_week.to_f / org_proposals.to_f) * 100).round
  end

  def proposals_added_on_average
    (self.created_proposals.count / weeks_active).round
  end
  def proposals_added_on_average_percentage
    org_proposals = (Proposal.count / organization.weeks_active).round
    org_proposals = 1 if org_proposals == 0
    ((proposals_added_on_average.to_f / org_proposals.to_f) * 100).round
  end

  def jobs_added_this_week
    proposal_sales.signed.where("(GREATEST(DATE(proposals.customer_sig_datetime), DATE(proposals.contractor_sig_datetime))) BETWEEN ? AND ?",  Time.now.beginning_of_week, Time.now.end_of_week).count
  end
  def jobs_added_this_week_percentage
    org_jobs = Proposal.signed.where("(GREATEST(DATE(proposals.customer_sig_datetime), DATE(proposals.contractor_sig_datetime))) BETWEEN ? AND ?",  Time.now.beginning_of_week, Time.now.end_of_week).count
    org_jobs = 1 if org_jobs == 0
    ((jobs_added_this_week.to_f / org_jobs.to_f) * 100).round
  end

  def jobs_added_last_week
    proposal_sales.where("(GREATEST(DATE(proposals.customer_sig_datetime), DATE(proposals.contractor_sig_datetime))) BETWEEN ? AND ?",  Time.now.beginning_of_week, Time.now.end_of_week).count
  end
  def jobs_added_last_week_percentage
    org_jobs = Proposal.signed.where("(GREATEST(DATE(proposals.customer_sig_datetime), DATE(proposals.contractor_sig_datetime))) BETWEEN ? AND ?",  Time.now.beginning_of_week, Time.now.end_of_week).count
    org_jobs = 1 if org_jobs == 0
    ((jobs_added_last_week.to_f / org_jobs.to_f) * 100).round
  end

  def jobs_added_on_average
    (self.proposal_sales.signed.count / weeks_active).round
  end
  def jobs_added_on_average_percentage
    org_jobs = (Proposal.signed.count / organization.weeks_active).round
    org_jobs = 1 if org_jobs == 0
    ((jobs_added_on_average.to_f / org_jobs.to_f) * 100).round
  end

  def total_expenses
    expenses.not_deleted.sum(:amount)
  end

  def total_payout
    timecards.paid.sum(:amount)
  end

  def appointments_booked(time_range=false)
    mAppointments = self.appointments.not_deleted
    mAppointments = mAppointments.in_time_range(time_range.first, time_range.last) if time_range
    mAppointments.count
  end

  def proposals_created(time_range=false)
    mProposals = self.created_proposals.not_deleted
    mProposals = mProposals.where('created_at BETWEEN ? AND ?', time_range.first, time_range.last) if time_range
    mProposals.count
  end

  def fetch_proposals_created(time_range=false)
    mProposals = self.created_proposals.not_deleted
    mProposals = mProposals.where('created_at BETWEEN ? AND ?', time_range.first, time_range.last) if time_range
    mProposals
  end

  def fetch_proposals_accepted time_range=false
    mProposals = self.proposal_sales.accepted
    mProposals = mProposals.where('(GREATEST(DATE(customer_sig_datetime), DATE(contractor_sig_datetime))) BETWEEN ? AND ?', time_range.first, time_range.last) if time_range
    mProposals
  end

  def fetch_proposals_declined(time_range=false)
    self.fetch_proposals_created(time_range).where(proposal_state: 'Declined')
  end

  def proposals_accepted(time_range=false)
    fetch_proposals_accepted(time_range).count
  end

  def success_rate(time_range=false)
    pa = proposals_accepted(time_range).to_f
    pd =  proposals_added(time_range).to_f
    if pd != 0
      sr = ( ( pa / pd ) * 100 ).round
    else
      sr = 0
    end
  end

  def fetch_jobs_sold(time_range=false)
    fetch_proposals_accepted(time_range).includes(:job).where("jobs.deleted_at IS NULL")
  end

  def jobs_sold(time_range=false)
    fetch_jobs_sold(time_range).map(&:job).uniq
  end

  def jobs_sold_count(time_range=false)
    jobs_sold(time_range).count
  end

  def jobs_sold_valuation(time_range=false)
    jobs_sold(time_range).sum(&:calculated_amount)
  end

  def fetch_jobs_completed(time_range=false)
    mJobs = fetch_jobs_sold.where("jobs.state = 'Completed'")
    mJobs = mJobs.joins(job: :activities).where('activities.data LIKE ? AND activities.created_at BETWEEN ? AND ?', '%to: Completed%', time_range.first, time_range.last) if time_range
    mJobs = mJobs.map(&:job).uniq
    mJobs
  end

  def jobs_completed(time_range=false)
    fetch_jobs_completed(time_range).count
  end

  def jobs_completed_valuation(time_range=false)
    fetch_jobs_completed(time_range).sum(&:calculated_amount)
  end

  def map_url
    "https://maps.google.com/?q=#{full_address}"
  end

  # Used for weekly average calculation.
  def weeks_active
    (Time.now - created_at) / 1.week
  end

  def capitalize_names
    self.first_name = self.first_name.capitalize
    self.last_name = self.last_name.capitalize
  end

  def self.find_for_google_oauth2(oauth, signed_in_resource)
    credentials = oauth.credentials
    data = oauth.info
    signed_in_resource.update_attributes(google_email: data["email"],
      google_auth_token: credentials.token,
      google_auth_expires_at: Time.at(credentials.expires_at),
      google_auth_refresh_token: credentials.refresh_token,
      connected_to_google: true
    )

    signed_in_resource
  end

  def google_auth_token_expired?
    google_auth_expires_at < Time.now ? true : false
  end

  def has_google_credentials?
    google_auth_token.present? && google_auth_refresh_token.present?
  end

  def appointments_with_google_events(date=nil)
    appointments = []
    if date.present?
      appointments = self.appointments.on_day(date).to_a
      appointments.concat(self.google_events.on_day(date).to_a) if self.connected_to_google?
    else
      appointments = self.appointments.to_a
      appointments.concat(self.google_events.to_a)
    end
    appointments = appointments.sort_by &:start_datetime
  end

  private

  def create_organization
    return if self.organization_id || !self.can_manage?
    organization = Organization.create!(name: self.organization_name, email: self.email)
    self.organization_id = organization.id
  end

  def check_organization_user_count
    if self.active_changed? && self.active
      return true if !self.organization_id || self.organization.can_add_users?
      errors[:active] << "This organization's subscription does not allow for additional active users."
      return false
    end
  end

  def  update_stripe_email
    if role == 'Owner' && email_changed? && organization.stripe_customer_token.present?
      customer = Stripe::Customer.retrieve(organization.stripe_customer_token)
      if customer.present?
        customer.email = self.email
        customer.save
      end
    end
  end
  # It should not be possible to create/update a manager/owner/admin user with
  # limited permissions. By ensuring that is the case here, checks can be
  # simplified elsewhere.
  def check_permissions
    if role.in? ['Manager', 'Owner', 'Admin']
      PERMISSION_FLAGS.each { |flag| send("#{flag}=", true) }
    end
  end

  def send_welcome_email
    if self.is_owner?
      ActsAsTenant.with_tenant(nil) do
        UsersMailer.welcome(self).deliver
        UsersMailer.notify_admin(self).deliver
      end
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                                  :integer          not null, primary key
#  email                               :string(255)      default(""), not null
#  encrypted_password                  :string(255)      default(""), not null
#  reset_password_token                :string(255)
#  reset_password_sent_at              :datetime
#  remember_created_at                 :datetime
#  sign_in_count                       :integer          default(0)
#  current_sign_in_at                  :datetime
#  last_sign_in_at                     :datetime
#  current_sign_in_ip                  :string(255)
#  last_sign_in_ip                     :string(255)
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  organization_id                     :integer
#  last_name                           :string(255)
#  first_name                          :string(255)
#  phone                               :string(255)
#  address                             :string(255)
#  address2                            :string(255)
#  city                                :string(255)
#  region                              :string(255)
#  zip                                 :string(255)
#  active                              :boolean          default(TRUE)
#  can_view_leads                      :boolean          default(TRUE)
#  can_manage_leads                    :boolean          default(TRUE)
#  can_view_appointments               :boolean          default(TRUE)
#  can_manage_appointments             :boolean          default(TRUE)
#  can_view_all_jobs                   :boolean          default(TRUE)
#  can_view_own_jobs                   :boolean          default(TRUE)
#  can_manage_jobs                     :boolean          default(TRUE)
#  can_view_all_proposals              :boolean          default(TRUE)
#  can_view_assigned_proposals         :boolean          default(TRUE)
#  can_manage_proposals                :boolean          default(TRUE)
#  can_be_assigned_appointments        :boolean          default(TRUE)
#  can_be_assigned_jobs                :boolean          default(TRUE)
#  role                                :string(255)      default("Owner")
#  country                             :string(255)
#  pay_rate                            :decimal(9, 2)    default(0.0)
#  admin_can_view_failing_credit_cards :boolean          default(FALSE)
#  admin_can_view_billing_history      :boolean          default(FALSE)
#  admin_can_manage_accounts           :boolean          default(FALSE)
#  admin_can_manage_trials             :boolean          default(FALSE)
#  admin_can_manage_cms                :boolean          default(FALSE)
#  admin_can_become_user               :boolean          default(FALSE)
#  admin_receives_notifications        :boolean          default(FALSE)
#  super                               :boolean          default(FALSE)
#  can_make_timecards                  :boolean          default(TRUE)
#  language                            :string(255)      default("en"), not null
#  can_view_all_contacts               :boolean          default(FALSE)
#  can_manage_all_contacts             :boolean          default(FALSE)
#
