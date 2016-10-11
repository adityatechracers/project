# == Schema Information
#
# Table name: change_orders
#
#  id                      :integer          not null, primary key
#  change_description      :text
#  user_id                 :integer
#  proposal_id             :integer
#  version_id              :integer
#  proposal_amount_change  :decimal(9, 2)    default(0.0)
#  job_amount_change       :decimal(9, 2)    default(0.0)
#  budgeted_hours_change   :integer          default(0)
#  expected_start_date_new :date
#  expected_end_date_new   :date
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class ChangeOrder < ActiveRecord::Base
  attr_protected :id, :user_id, :proposal_id

  validate :proposal_is_accepted
  validates_presence_of :proposal_id, :user_id, :change_description
  validates_numericality_of :proposal_amount_change, :budgeted_hours_change, allow_blank: true

  belongs_to :proposal
  belongs_to :user

  default_scope ->{ order('created_at DESC') }
  scope :applied, ->{ where('version_id IS NOT NULL') }

  after_create :apply_changes
  after_create :send_notification
  before_update :prevent_update

  # There are certain fields we would only like to display to members of the
  # organization (not its customers).
  RESTRICTED_ATTRS = [ :budgeted_hours, :expected_start_date, :expected_end_date ]

  IGNORED_ATTRS    = [ :title, :updated_at, :created_at ]


  # Returns the paper_trail diff of applying the changes to the proposal. Will fail
  # if called on a change order without a version.
  def diff
    original_proposal_version.changeset
  end

  # Generates a human-readable summary of the changes by comparing the proposal's
  # papertrail versions prior to and following application of the change order.
  #
  # @param options [Object]
  #   show_restricted [Boolean] include changes to restricted attrs
  # @return [String] the change summary.
  def summary(options = {})
    "On #{created_at.strftime('%b. %-d, %Y at %-l:%M %P')}, #{user.name} #{changes(options).to_sentence}."
  end

  def original_proposal
    if original_proposal_version.present?
      original_proposal_version.reify(dup: true)
    else
      proposal
    end
  end

  def original_proposal_version
    if version_id.present?
      proposal.versions.where(id: version_id).first
    else
      nil
    end
  end

  def proposal_amount_changed?
    proposal_amount_change.present? && proposal_amount_change.abs > 0
  end

  protected

  def formatted_change_value(value)
    case value
    when NilClass then 'empty'
    when Date then I18n.l value
    when Float then number_to_currency(value)
    else value.to_s
    end
  end

  def changes(options = {})
    changes = diff
      .select { |attr, values| options[:show_restricted] || !attr.to_sym.in?(RESTRICTED_ATTRS) }
      .select { |attr, values| !attr.to_sym.in?(IGNORED_ATTRS) }
      .map do |attr, values|
        "changed the  <strong>#{attr.humanize.downcase}</strong> from #{formatted_change_value(values[0])} to #{formatted_change_value(values[1])}"
      end

    changes = ['created a change order'] unless changes.any?
    changes
  end

  def proposal_is_accepted
    unless proposal.accepted?
      errors.add(:base, 'A change order can only be applied to accepted proposals')
      false
    end
  end

  def apply_changes
    raise "This change order has already been applied in version #{version_id}." if version_id.present?

    previous_version = proposal.versions.last

    proposal.update_attributes!(
      amount:              (proposal.amount || 0) + proposal_amount_change.to_f,
      budgeted_hours:      (proposal.budgeted_hours || 0) + budgeted_hours_change.to_i,
      expected_start_date: expected_start_date_new || proposal.expected_start_date,
      expected_end_date:   expected_end_date_new || proposal.expected_end_date
    )

    # Apply the proposal amount change to the job amount. We don't copy it over
    # because the job amount is supposed to be the sum of a job's proposal
    # amounts.
    if proposal_amount_changed?
      proposal.job.update_attribute(:estimated_amount, proposal.job.estimated_amount + proposal_amount_change.to_f)
    end

    # Have to force an update if nothing changed on the proposal.
    # (i.e., only a change description was given.)
    proposal.touch_with_version if previous_version == proposal.versions.last

    update_column(:version_id, proposal.versions.last.id)
  end

  def prevent_update
    raise 'Change orders cannot be updated. Please create a new change order instead.'
  end

  def send_notification
    ProposalsMailer.change_order_notification(self.proposal, self).deliver
  end
end
