# == Schema Information
#
# Table name: organizations
#
#  id                             :integer          not null, primary key
#  name                           :string(255)
#  guid                           :string(255)
#  premium_override               :boolean
#  stripe_plan_id                 :string(255)
#  stripe_customer_token          :string(255)
#  last_payment_successful        :boolean
#  last_payment_date              :datetime
#  stripe_plan_name               :string(255)
#  name_on_credit_card            :string(255)
#  last_four_digits               :string(255)
#  address                        :string(255)
#  address_2                      :string(255)
#  city                           :string(255)
#  region                         :string(255)
#  zip                            :string(255)
#  email                          :string(255)
#  phone                          :string(255)
#  fax                            :string(255)
#  license_number                 :string(255)
#  logo_file_name                 :string(255)
#  logo_content_type              :string(255)
#  logo_file_size                 :integer
#  logo_updated_at                :datetime
#  timecard_lock_period           :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  active                         :boolean          default(TRUE)
#  trial_start_date               :datetime
#  embed_help_text                :text
#  embed_thank_you                :text
#  time_zone                      :string(255)
#  trial_end_date                 :datetime
#  country                        :string(255)
#  default_signature              :text
#  auto_sign_proposals            :boolean          default(FALSE), not null
#  proposal_style                 :string(255)      default("CorkCRM"), not null
#  uses_crew_commissions          :boolean          default(FALSE), not null
#  website_url                    :string(255)
#  proposal_banner_text           :text
#  proposal_paper_size            :string(255)      default("A4"), not null
#  feedback_portal_text           :text
#  feedback_portal_show_signature :boolean          default(FALSE), not null
#  proposal_options               :text
#  num_allowed_users              :integer          default(1), not null
#  parent_organization_id         :integer
#  user_signatures                :text
#

class Organization < ActiveRecord::Base
  attr_protected :id
  attr_accessor :stripe_card_token
  serialize :user_signatures

  has_attached_file :logo, :styles => {:medium => "300x300>", :thumb => "100x100>"}, :default_url => "/assets/default-org-icon.gif"

  before_validation :set_default_timezone
  before_save :save_payment
  before_create :set_default_subscription
  before_create :generate_guid
  after_create :clone_email_templates, :clone_proposal_templates, :clone_lead_sources, :clone_expense_categories

  include QuickBooksConcern::Organization

  has_many :users, dependent: :nullify
  has_many :crews
  has_many :jobs
  has_many :appointments
  has_many :contacts
  has_many :communications
  has_many :proposals
  has_many :email_templates
  has_many :proposal_templates
  has_many :lead_sources
  has_many :expense_categories
  has_many :vendor_categories
  has_many :payments, through: :jobs
  has_many :expenses, through: :jobs
  has_one :owner, :class_name => 'User', :conditions => "users.role = 'Owner' OR users.role = 'Admin'"
  belongs_to :parent_organization, :class_name => 'Organizations', :foreign_key => :parent_organization_id

  scope :active, where(:active => true)
  scope :inactive, where(:active => false)
  scope :trials, where(:stripe_plan_id => 'Free')
  scope :paid, where("stripe_plan_id != ?",'Free')

  paginates_per 15

  validates :name, :email, presence: true
  validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone.zones_map(&:name), allow_blank: true

  PREFERRED_TIMEZONES = {
    -5 => "Eastern Time (US & Canada)",
    -6 => "Central Time (US & Canada)",
    -7 => "Mountain Time (US & Canada)",
    -8 => "Pacific Time (US & Canada)",
    -9 => "Alaska", -10 => "Hawaii"
  }

  module ProposalStyle
    CORKCRM = 'CorkCRM'
    SIMPLE  = 'Simple'

    def self.collection
      [CORKCRM, SIMPLE]
    end
  end

  module ProposalPaperSize
    A4     = 'A4'
    LEGAL  = 'Legal'
    LETTER = 'Letter'

    def self.collection
      [A4, LEGAL, LETTER]
    end
  end

  class << self
    def send_trial_2_day_follow_ups
      trials.each_using_time_zone do |org|
        if org.trial_start_date.to_date == Time.zone.now.to_date - 2.days
          OrganizationsMailer.trial_2_day_follow_up(org).deliver
        end
      end
    end

    def send_trial_7_day_follow_ups
      trials.each_using_time_zone do |org|
        if org.trial_start_date.to_date == Time.zone.now.to_date - 7.days
          OrganizationsMailer.trial_7_day_follow_up(org).deliver
        end
      end
    end

    def send_trial_10_day_follow_ups
      trials.each_using_time_zone do |org|
        if org.trial_start_date.to_date == Time.zone.now.to_date - 10.days
          OrganizationsMailer.trial_10_day_follow_up(org).deliver
        end
      end
    end

    def send_trial_expiration_notices
      trials.each_using_time_zone do |org|
        if org.trial_end_date.to_date == Time.zone.now.to_date
          OrganizationsMailer.trial_expiration_notice(org).deliver
        end
      end
    end

    def send_expired_7_day_follow_ups
      trials.each_using_time_zone do |org|
        if org.trial_end_date.to_date == Time.zone.now.to_date - 7.days
          OrganizationsMailer.expired_7_day_follow_up(org).deliver
        end
      end
    end

    def send_expired_1_month_follow_ups
      trials.each_using_time_zone do |org|
        if org.trial_end_date.to_date == Time.zone.now.to_date - 30.days
          OrganizationsMailer.expired_1_month_follow_up(org).deliver
        end
      end
    end

    def send_active_1_month_follow_ups
      paid.each_using_time_zone do |org|
        if org.created_at.to_date == Time.zone.now.to_date - 30.days
          OrganizationsMailer.active_1_month_follow_up(org).deliver
        end
      end
    end

    def preferred_timezone(offset_hours)
      offset_hours -= 1 if Time.dst?
      ActiveSupport::TimeZone[Organization::PREFERRED_TIMEZONES[offset_hours] || offset_hours].name
    end

    def each_using_time_zone
      all.each do |org|
        Time.use_zone(org.time_zone) { yield org }
      end
    end

    def send_failed_payment_reminder
      paid.each_using_time_zone do |org|
        if org.last_failed_payment_date
          if org.last_failed_payment_date.to_date == Time.zone.now.to_date - 1.days
            SubscriptionsMailer.failed_payment_reminder(org, 1).deliver
          elsif org.last_failed_payment_date.to_date == Time.zone.now.to_date - 2.days
            SubscriptionsMailer.failed_payment_reminder(org, 2).deliver
          elsif org.last_failed_payment_date.to_date == Time.zone.now.to_date - 5.days
            SubscriptionsMailer.failed_payment_reminder(org, 5).deliver
          end
        end
      end
    end
  end

  def language
    owner.try(:language) || User::Language::ENGLISH
  end

  def failed_payment_cancellation
    self.update_attributes(stripe_plan_id: nil, stripe_plan_name: nil, active: false)
    self.save(validate: false)
  end

  def is_trial_account?
    self.stripe_plan_id == 'Free'
  end

  def is_paid_account?
    self.stripe_plan_id.present? && self.stripe_plan_id != 'Free'
  end

  def trial_active?
    trial_end_date.present? && trial_days_remaining > 0
  end

  def trial_days_remaining
    ((self.trial_end_date - Time.zone.now) / 1.day).round
  end

  def active_users
    self.users.where(:active => true)
  end

  def employees
    self.users.where(:role => 'Employee').all
  end

  def plan
    Plan.new(self.stripe_plan_id)
  end

  def plan_name
    if stripe_plan_id == 'Free' && !trial_active?
      'Expired'
    else
      stripe_plan_id
    end
  end

  def can_add_users?
    self.users.where(active: true).count < num_allowed_users
  end

   def number_of_active_users
    users.active_users.count
  end

  # Calling these "managed organizations" in the frontend
  def child_organizations
    Organization.where(parent_organization_id: id)
  end

  # This method may be run as a managing organization, so we have to remove
  # the tenancy.
  def stats(timeframe = nil)
    ActsAsTenant.with_tenant(nil) do
      jobs_query = timeframe.present? ? jobs.from_time_range(timeframe.begin, timeframe.end) : jobs
      {
        id: id,
        profit: jobs_query.sum(&:expected_profit),
        revenue: jobs_query.sum(&:total_payments), # Should maybe base on payment date instead.
        expenses: jobs_query.sum(&:total_expenses) + jobs_query.sum(&:expected_payout),
        job_count: jobs_query.transcended.count,
        lead_count: jobs_query.leads.count
      }
    end
  end

  # Can't be own parent and child organizations can't be parent's parent.
  def eligible_parent_organizations
    Organization.where('id != :id AND (parent_organization_id IS NULL OR parent_organization_id != :id)', id: id)
  end

  def has_address?
    self.address.present? && self.city.present? && self.region.present?
  end

  def full_address
    [self.address, self.address_2, self.city, self.region, self.zip]
      .select { |c| c.present? }
      .join(', ')
  end

  def condensed_address
    components = [self.address, self.city]
    components.each_with_index {|c,i| components.delete(c) if c.blank? }
    components.join(", ")
  end

  def cancel_subscription
    if self.stripe_customer_token.present?
      begin
        cu = Stripe::Customer.retrieve(self.stripe_customer_token)
        cu.cancel_subscription
      rescue Stripe::InvalidRequestError => e
        # If this happens, the subscription was probably canceled/changed
        # manually within Stripe.
        #
        # There's not much we can do about it, so we'll notify and proceed with
        # canceling the subscription.
        ExceptionNotifier::Notifier.background_exception_notification(e, data: {
          notes: "Account was canceled, but the Stripe subscription could not "\
                 "be canceled. This could mean that it was manually canceled or changed "\
                 "within Stripe. You may want to have a look.",
          organization: self.to_yaml
        }).deliver
      end

      # TODO: Add a cancelled region?
      self.stripe_plan_id = nil
      self.active = false
      self.last_failed_payment_date = nil
      self.save
    end
  end

  def payment_succeeded!
    self.last_payment_successful = true
    self.last_payment_date = Time.zone.now.to_datetime
    self.last_failed_payment_date = nil
    self.save(:validate => false)
  end

  def payment_failed!
    self.last_payment_successful = false
    self.last_failed_payment_date = Time.zone.now.to_datetime unless self.last_failed_payment_date
    self.save(:validate => false)
  end

  def email
    read_attribute(:email) || self.owner.try(:email)
  end

  def missing_stuff?
    self.name.blank? || self.address.blank? || self.city.blank? || self.region.blank? || self.zip.blank? || self.phone.blank?
  end

  def timecard_locks_enabled?
    self.timecard_lock_period == 'Weekly'
  end

  def map_url
    "https://maps.google.com/?q=#{self.full_address}"
  end

  def clone_email_template(template)
    dupe = template.dup
    dupe.organization_id = self.id
    dupe.master = false
    dupe.priority = template.priority
    dupe.save
  end

  def clone_proposal_template(template)
    dupe = template.dup
    dupe.organization_id = self.id
    dupe.save

    template.section_templates.each do |pts|
      dupe_s = pts.dup
      dupe_s.proposal_template_id = dupe.id
      dupe_s.save

      pts.item_templates.each do |pti|
        dupe_i = pti.dup
        dupe_i.proposal_template_section_id = dupe_s.id
        dupe_i.save
      end
    end
  end

  def clone_lead_source(lead_source)
    dupe = lead_source.dup
    dupe.organization_id = self.id
    dupe.save
  end

  def clone_expense_category(expense_category)
    dupe = expense_category.dup
    dupe.organization_id = self.id
    dupe.save
  end

  def remove_email_template(template_name)
    matching = self.email_templates.where(:name => template_name)
    return unless matching.any?
    matching.each {|m| m.destroy }
  end

  def remove_proposal_template(template_name)
    matching = self.proposal_templates.where(:name => template_name)
    return unless matching.any?
    matching.each {|m| m.destroy }
  end

  def remove_lead_source(lead_source_name)
    matching = self.email_templates.where(:name => template_name)
    return unless matching.any?
    matching.each {|m| m.destroy }
  end

  def self.remove_email_template(template_name)
    Organization.all.each {|o| o.remove_email_template(template_name)}
  end

  def self.remove_proposal_template(template_name)
    Organization.all.each {|o| o.remove_proposal_template(template_name)}
  end

  def self.remove_lead_source(lead_source_name)
    Organization.all.each {|o| o.remove_lead_source(lead_source_name)}
  end

  def upgrade_cloned_data
    upgrade_email_templates
    upgrade_proposal_templates
    upgrade_lead_sources
    upgrade_expense_categories
  end

  def upgrade_email_templates
    EmailTemplate.where(master: true).each do |t|
      clone_email_template(t) unless email_templates.where(name: t.name, lang: t.lang).any?
    end
  end

  def upgrade_proposal_templates
    ProposalTemplate.where(organization_id: 0).each do |pt|
      clone_proposal_template(pt) unless proposal_templates.where(name: pt.name).any?
    end
  end

  def upgrade_lead_sources
    LeadSource.where(organization_id: 0).each do |ls|
      clone_lead_source(ls) unless lead_sources.where(name: ls.name).any?
    end
  end

  def upgrade_expense_categories
    ExpenseCategory.where(organization_id: 0).each do |ec|
      clone_expense_category(ec) unless expense_categories.where(name: ec.name).any?
    end
  end

  def self.upgrade_cloned_data
    Organization.all.each {|o| o.upgrade_cloned_data}
  end

  def self.upgrade_email_templates
    Organization.all.each {|o| o.upgrade_email_templates}
  end

  def self.upgrade_proposal_templates
    Organization.all.each {|o| o.upgrade_proposal_templates}
  end

  def self.upgrade_email_templates
    Organization.all.each {|o| o.upgrade_email_templates}
  end

  # Used for weekly average calculation.
  def weeks_active
    (Time.now - created_at) / 1.week
  end

  def reporting_years
    created_at.year..Time.now.year
  end

  def update_card(card_token)
    begin
      if self.stripe_customer_token.present?
        customer = Stripe::Customer.retrieve(self.stripe_customer_token)
        card = customer.cards.create(card: card_token)
        customer.default_card = card.id
        new_customer = customer.save
        self.last_four_digits = card.last4
        self.stripe_customer_token = new_customer.id
        self.save
        self.attempt_failed_invoices(new_customer) if self.last_failed_payment_date
        return true
      end
    rescue Stripe::InvalidRequestError => e
      puts e.message
      logger.error "Stripe error while updating card info: #{e.message}"
      errors.add :base, "#{e.message}"
      false
    rescue Stripe::CardError => e
      puts e.message
      logger.error "Stripe error while updating card info: #{e.message}"
      errors.add :card, "#{e.message}"
      false
    end
  end
  def attempt_failed_invoices(customer)
    # call this method only when rescuing Stripe::CardError
    failed_invoice = customer.invoices[:data].select{ |i| !i['closed'] && !i['forgiven'] }
    unless failed_invoice.empty?
      invoice_attempt = failed_invoice.first.pay
      if invoice_attempt['closed']
        self.last_failed_payment_date = nil
        self.last_payment_successful = true
        self.save
        return true
      end
    end
  end

  def update_stripe_subscription_in_cork(plan)
    self.update_attributes(stripe_plan_id: plan, stripe_plan_name: plan)
    self.save(validate: false)
  end

  private

  def save_payment
    return true if self.stripe_card_token.nil? || !self.stripe_plan_id_changed?

    if self.stripe_customer_token.present?
      customer = Stripe::Customer.retrieve(self.stripe_customer_token)
      params = { :plan => self.stripe_plan_id }
      params[:card] = stripe_card_token if stripe_card_token.present?
      customer.update_subscription(params)
      self.last_four_digits = customer.active_card.last4
      self.stripe_customer_token = customer.id
      self.active = true
      self.last_failed_payment_date = nil

      customer.invoices.each do |i|
        if !i['forgiven'] && !i['closed']
          i.closed = true
          i.save
        end
      end
    elsif self.stripe_plan_id == "Free"
      set_free_trial
    else
      customer = Stripe::Customer.create(description: self.name, card: stripe_card_token, email: self.owner.email, plan: stripe_plan_id)
      self.last_four_digits = customer.active_card.last4
      self.stripe_customer_token = customer.id
      self.last_payment_successful = true
    end

    # If changing plans, we need to adjust the number of allowed users to the new
    # plan's limit.
    self.num_allowed_users = plan.num_users

    true

    rescue Stripe::InvalidRequestError => e

    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add "", "There was a problem with your credit card."
    false
    rescue Stripe::CardError => e

    self.changes.each {|k,vs| self.send("reset_#{k}!")}
    self.stripe_card_token = nil
    puts e.message
    logger.error "Stripe error while updating card info: #{e.message}"
    errors.add :card, "#{e.message}"
    false
  end

  def set_free_trial
    self.stripe_plan_id = self.stripe_plan_name = "Free"
    self.last_payment_successful = true
    self.trial_start_date = Time.zone.now
    self.trial_end_date = Time.zone.now + Plan.trial_duration.days
  end

  def set_default_subscription
    set_free_trial
  end

  def set_default_timezone
    self.time_zone ||= 'Eastern Time (US & Canada)'
  end

  def generate_guid
    self.guid = SecureRandom.uuid
  end

  def clone_email_templates
    EmailTemplate.where(master: true).each do |t|
      clone_email_template(t)
    end
  end

  def clone_proposal_templates
    ProposalTemplate.where(organization_id: 0).each do |pt|
      clone_proposal_template(pt)
    end
  end

  def clone_lead_sources
    LeadSource.where(organization_id: 0).each do |ls|
      clone_lead_source(ls)
    end
  end

  def clone_expense_categories
    ExpenseCategory.where(organization_id: 0).each do |ec|
      clone_expense_category(ec)
    end
  end
end
