class Proposal < ActiveRecord::Base
  attr_accessible :address, :address2, :city, :country, :contractor_id, :job_id, :license_number, :organization_id,
     :proposal_date, :proposal_number, :proposal_template_id, :sales_person_id, :region,
    :title, :zip, :amount, :notes, :customer_sig_printed_name, :customer_sig, :customer_sig_user_id,
    :contractor_sig_printed_name, :contractor_sig, :contractor_sig_user_id, :section_responses_attributes,
    :proposal_state, :deposit_amount, :budgeted_hours, :customer_sig_datetime, :contractor_sig_datetime, :added_by,
    :expected_start_date, :expected_end_date, :proposal_address

  include QuickBooksConcern::Proposal

  def self.PROPOSAL_FIELDS_EXPORT
    { 'proposal_number'=> 'Proposal Number',
      'title' =>'Proposal Title',
      'address' =>'Address',
      'address2' =>'Address 2',
      'city' =>'City',
      'country' =>'Country',
      'zestimate' => 'Contact Zestimate (USD)',
      'proposal_state' =>'Proposal State',
      'amount'=> 'Amount',
      'proposal_amount_change' => 'Net Change Order Amounts',
      'budgeted_hours'=> 'Budgeted Hours',
      'budgeted_hours_change' => 'Net Budgeted Hour Changes',
      'expected_start_date'=> 'Expected Start Date',
      'expected_end_date'=> 'Expected End Date',
      'sales_person' => 'Proposal Assigned To',
      'proposal_template' => 'Proposal Template',
      'deleted' => 'Deleted At' }
  end

  def self.export(organization_id)
    sql = <<-SQL
      SELECT p.proposal_number, p.title, p.address, p.address2, p.city, p.country, c.zestimate, p.proposal_state,
      p.amount, COALESCE(SUM(proposal_amount_change), 0) AS proposal_amount_change, p.budgeted_hours,
      COALESCE(SUM(budgeted_hours_change),0) as budgeted_hours_change, p.expected_start_date, p.expected_end_date,
      TRIM(u.first_name) || ' ' || TRIM(u.last_name) AS sales_person, pt.name AS proposal_template,
      CASE WHEN p.deleted_at IS NOT NULL THEN p.deleted_at ELSE NULL END AS deleted
      FROM proposals AS p
      LEFT JOIN change_orders AS co ON co.proposal_id = p.id
      INNER JOIN users AS u ON u.id = p.sales_person_id
      INNER JOIN proposal_templates as pt ON pt.id = p.proposal_template_id
      LEFT JOIN jobs as j ON p.job_id = j.id
      LEFT JOIN contacts as c ON j.contact_id = c.id
      WHERE p.organization_id = #{organization_id}
      GROUP BY p.id, u.first_name, u.last_name, pt.name, c.zestimate
      ORDER BY p.deleted_at DESC;
    SQL

    results = ActiveRecord::Base.connection.execute(sql)
  end

  scope :active, not_deleted.where(:proposal_state => 'Active')
  scope :accepted, not_deleted.where(:proposal_state => 'Accepted')
  scope :declined, not_deleted.where(:proposal_state => 'Declined')
  scope :issued, not_deleted.where(:proposal_state => "Issued")
  scope :not_declined, not_deleted.where('proposal_state != ?', 'Declined')
  scope :unaccepted, not_deleted.where("customer_sig_printed_name IS NULL OR contractor_sig_printed_name IS NULL")
  scope :signed, not_deleted.where('customer_sig_printed_name IS NOT NULL AND contractor_sig_printed_name IS NOT NULL')
  scope :updated_in_time_range, lambda{ |s,e| where("proposals.updated_at BETWEEN ? AND ?", s, e).order("proposals.updated_at ASC")}
  scope :created_in_time_range, lambda{ |s,e| where("proposals.created_at BETWEEN ? AND ?", s, e).order("proposals.created_at ASC")}

  belongs_to :job
  belongs_to :template, :class_name => "ProposalTemplate", :foreign_key => "proposal_template_id"
  belongs_to :sales_person, :class_name => "User"
  belongs_to :contractor, :class_name => "User"
  belongs_to :creator, :class_name => "User", :foreign_key => "added_by"
  has_one :contact, :through => :job
  has_many :section_responses, :class_name => "ProposalSectionResponse"
  has_many :item_responses, :class_name => "ProposalItemResponse", :through => :section_responses
  has_many :change_orders
  has_many :proposal_files

  validates_presence_of :job, :amount, :budgeted_hours
  validates_numericality_of :budgeted_hours, :amount, less_than_or_equal_to: 9999999.99

  accepts_nested_attributes_for :section_responses

  has_paper_trail
  acts_as_tenant :organization
  paginates_per 10

  before_create :set_guid, :update_job_estimated_amount
  before_save :set_state, :set_title, :fix_amount # :assign_proposal_number removed
  after_save :send_contract_signed_notifications
  after_save :set_job_state
  after_create :auto_sign_proposal
  validate :deposit_amount_less_or_equal_proposal_amount

  STATES = ["Active", "Issued", "Accepted", "Declined"]

  def deposit_amount_less_or_equal_proposal_amount
    fix_amount
    if self.deposit_amount > self.amount
      errors.add(:deposit_amount, "cannot be greater than proposal amount")
    end
  end

  def deposit_amount
    self[:deposit_amount] || 0
  end
  class << self
    # TODO: Ideally these should be wrapped in a use time zone block for each org.

    # Note: Using X.days in lieu of week/month helpers for easier testing.
    def send_issued_2_day_reminders
      send_reminders(issued, Time.zone.now.to_date - 2.days) do |p|
        ProposalsMailer.issued_2_day_reminder(p).deliver
      end
    end

    def send_issued_1_week_reminders
      send_reminders(issued, Time.zone.now.to_date - 7.days) do |p|
        ProposalsMailer.issued_1_week_reminder(p).deliver
      end
    end

    def send_issued_1_month_reminders
      send_reminders(issued, Time.zone.now.to_date - 30.days) do |p|
        ProposalsMailer.issued_1_month_reminder(p).deliver
      end
    end

    def send_issued_2_month_reminders
      send_reminders(issued, Time.zone.now.to_date - 60.days) do |p|
        ProposalsMailer.issued_2_month_reminder(p).deliver
      end
    end

    def send_issued_3_month_reminders
      send_reminders(issued, Time.zone.now.to_date - 90.days) do |p|
        ProposalsMailer.issued_3_month_reminder(p).deliver
      end
    end

    def send_reminders(proposals, created_at)
      proposals.where('date(created_at) = ?', created_at).each do |p|
        ActsAsTenant.with_tenant(p.organization) { yield p }
      end
    end
  end

  def updated_by
    if self.versions.last.event == "update"
      user_id = self.versions.last.whodunnit
      if user_id.present?
        user = User.find(user_id)
        return user.name
      end
    end
    return nil
  end

  def issued_at
    self.versions.each do |version|
      if version.changeset.has_key? :proposal_state and version.changeset[:proposal_state].second == "Issued"
        return version.created_at
      end
    end
    return nil
  end

  def issued_by
    self.versions.each do |version|
      if version.changeset.has_key? "proposal_state" and version.changeset[:proposal_state].second == "Issued"
        user_id = version.whodunnit
        user = User.find user_id
        return user.name
      end
    end
    return nil
  end

  def accepted_at
    self.versions.each do |version|
      if version.changeset.has_key? :proposal_state and version.changeset[:proposal_state].second == "Accepted"
        return version.created_at
      end
    end
    return nil
  end

  def accepted_by
    self.versions.each do |version|
      if version.changeset.has_key? "proposal_state" and version.changeset[:proposal_state].second == "Accepted"
        user_id = version.whodunnit
        user = User.find user_id
        return user.name
      end
    end
    return nil
  end

  def declined_at
    self.versions.each do |version|
      if version.changeset.has_key? :proposal_state and version.changeset[:proposal_state].second == "Declined"
        return version.created_at
      end
    end
    return nil
  end

  def declined_by
    self.versions.each do |version|
      if version.changeset.has_key? "proposal_state" and version.changeset[:proposal_state].second == "Declined"
        user_id = version.whodunnit
        user = User.find user_id
        return user.name
      end
    end
    return nil
  end

  def assigned_list_cell
    "<td class='footable'>" + [self.sales_person.try(:name)].compact.uniq.join('<br />') + "</td>"
  end

  def contact_emails
    ProposalsMailer.contacts(self)
  end

  def active?
    self.proposal_state == 'Active'
  end

  def accepted?
    self.proposal_state == 'Accepted'
  end

  def issued?
    self.proposal_state == 'Issued'
  end

  def declined?
    self.proposal_state == 'Declined'
  end



  def render_contract_agreement
    return self.agreement if self.agreement.present? #if accepted?
    tokens = {
      'customer_first_name'     => job.contact.first_name,
      'customer_last_name'      => job.contact.last_name,
      'customer_address'        => job.contact.full_address,
      'customer_phone_number'   => helpers.number_to_phone(job.contact.phone, area_code: true),
      'contractor_first_name'   => contractor.try(:first_name),
      'contractor_last_name'    => contractor.try(:last_name),
      'contractor_phone_number' => helpers.number_to_phone(contractor.try(:phone), area_code: true),
      'proposal_total'          => "$#{'%.2f' % amount}",
      'proposal_notes'          => notes,
      'expected_start_date'     => expected_start_date.present? ? I18n.l(expected_start_date) : '',
      'expected_end_date'       => expected_end_date.present?   ? I18n.l(expected_end_date)   : '',
      'your_billing_address'    => organization.full_address,
      'your_billing_city'       => organization.city,
      'your_billing_state'      => organization.region,
    }
    Liquid::Template.parse(self.template.agreement).render(tokens)
  end

  def customer_signed?
    self.customer_sig_printed_name.present?
  end

  def contractor_signed?
    self.contractor_sig_printed_name.present?
  end

  def set_guid
    self.guid = SecureRandom.uuid
  end

  def set_state
    return if self.proposal_state == "Declined"

    # Send email when transitioning from Active to Accepted
    if self.customer_signed? && self.contractor_signed?
      if ['Issued', 'Active'].include? self.proposal_state
        lock_contract
        send_proposal_contract
      end
      return self.proposal_state = "Accepted"
    end
    return if self.proposal_state == "Issued"
    self.proposal_state = 'Active'
  end

  def send_proposal_contract
    begin
      ProposalsMailer.proposal_contract(self).deliver
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e, data: { proposal: self.to_yaml }).deliver
    end
  end

  def fix_amount
    self.amount = self.amount.to_s.scan(/\b-?[\d.]+/).join.to_d
  end

  def set_job_state
    self.job.set_state
    self.job.save
  end

  def lock_contract
    self.agreement = render_contract_agreement
  end

  def pdf_name
    "#{self.proposal_number}-#{self.title.parameterize}"
  end

  def title
    if read_attribute(:title).present?
      read_attribute(:title)
    elsif job.try(:contact).present?
      "#{job.contact.backwards_name} - ##{proposal_number}"
    else
      "##{proposal_number}"
    end
  end

  def amount=(num)
    num.gsub!(',', '') if num.is_a? String
    self[:amount] = num
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

  def map_url
    "https://maps.google.com/?q=#{self.full_address}"
  end

  def signed_for_contractor
    if contractor_sig_user_id
      return User.find(contractor_sig_user_id)
    else
      return contractor
    end
  end

  def update_job_estimated_amount
    self.job.estimated_amount += self.amount
    self.job.save
  end

  def add_files(primary_file, secondary_files=[], attachment_files=[])
    ActiveRecord::Base.transaction do
      current_primary_file = self.proposal_files.select { |f| f.is_primary_proposal_file? }
      current_primary_file.first.destroy if primary_file && current_primary_file && current_primary_file.first
      return false unless add_files_by_type(primary_file, PersonalProposalFile.name)
      return false unless add_files_by_type(secondary_files, SecondaryProposalFile.name)
      return false unless add_files_by_type(attachment_files, AttachmentProposalFile.name)
    end
    return true
  end

  private

  def add_files_by_type(files, cork_file_type)
    files = [files] if files && !files.is_a?(Array)
    if files && !files.empty?
      files.each do |f|
        uploaded = self.proposal_files.create(file: f, original_file_name: f.original_filename, type: cork_file_type)
        return false unless uploaded
      end
    end
    return true
  end

  # def assign_proposal_number
  #   return if self.proposal_number.present?
  #   # Will need to rewrite some things if this ever happens.
  #   raise 'Too many proposals' if Proposal.count > 50000
  #
  #   # Find an unused (within org) 5-digit number.
  #   self.proposal_number = 10000 + rand(89999)
  #   while Proposal.find_by_proposal_number(self.proposal_number).present?
  #     self.proposal_number = 10000 + rand(89999)
  #   end
  # end

  def set_title
    # If proposal title isn't set, save our stand-in title so that it can later be edited
    if read_attribute(:title).blank?
      self.title = self.title
    end
  end

  def auto_sign_proposal
    if organization.present? && organization.auto_sign_proposals?
      found = false
      signed_signature = ""
      signed_user_id = ""
      if organization.user_signatures
        organization.user_signatures.each do |v|
          if self.sales_person_id == v[:signature_for_user_id].to_i
            signed_signature = v[:signature_value]
            signed_user_id = v[:signature_for_user_id].to_i
            found = true
          end
        end
      end
      if found == true
        update_attributes(
          contractor_sig_printed_name: User.find(signed_user_id).name,
          contractor_sig: signed_signature,
          contractor_sig_user_id: signed_user_id,
          contractor_sig_datetime: Time.zone.now
        )
      else
        update_attributes(
          contractor_sig_printed_name: organization.owner.try(:name),
          contractor_sig: organization.default_signature,
          contractor_sig_user_id: organization.owner.id,
          contractor_sig_datetime: Time.zone.now
        )
      end

    end
  end

  def send_contract_signed_notifications
    if customer_signed? && customer_sig_printed_name_changed?
      ProposalsMailer.contract_signed_confirmation(self).deliver
      ProposalsMailer.contract_signed_notification(self).deliver
    end
  end

  def helpers
    ActionController::Base.helpers
  end

end

# == Schema Information
#
# Table name: proposals
#
#  title                       :string(255)
#  job_id                      :integer
#  proposal_template_id        :integer
#  proposal_number             :integer
#  address                     :string(255)
#  city                        :string(255)
#  region                      :string(255)
#  zip                         :string(255)
#  license_number              :string(255)
#  proposal_date               :date
#  sales_person_id             :integer
#  contractor_id               :integer
#  organization_id             :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  address2                    :string(255)
#  country                     :string(255)
#  notes                       :text
#  signed_by                   :integer
#  customer_sig_printed_name   :string(255)
#  customer_sig                :text
#  customer_sig_user_id        :integer
#  contractor_sig_printed_name :string(255)
#  contractor_sig              :text
#  contractor_sig_user_id      :integer
#  proposal_state              :string(255)
#  amount                      :decimal(9, 2)    default(0.0)
#  agreement                   :text
#  customer_sig_datetime       :datetime
#  contractor_sig_datetime     :datetime
#  guid                        :string(255)      not null
#  budgeted_hours              :integer          default(0)
#  id                          :integer          not null, primary key
#  deleted_at                  :datetime
#  added_by                    :integer
#  expected_start_date         :date
#  expected_end_date           :date
#
