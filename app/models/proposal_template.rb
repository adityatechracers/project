class ProposalTemplate < ActiveRecord::Base
  attr_accessible :name, :organization_id, :proposal_template_sections_attributes, :active, :agreement, :type

  has_many :proposals
  has_many :section_templates, :order => :position, :class_name => 'ProposalTemplateSection'
  has_many :item_templates, :class_name => 'ProposalTemplateItem', :through => :proposal_template_sections

  scope :global, not_deleted.where("organization_id = 0")
  scope :active, not_deleted.where(active: true)

  accepts_nested_attributes_for :section_templates

  acts_as_tenant :organization
  has_paper_trail

  before_create :add_proposal_to_name

  validates :agreement, :liquid => true

  def is_upload_your_own?
    false
  end

  def render_sample_contract_agreement
    return '' if self.agreement.blank?

    tokens = [
      'customer_first_name', 'customer_last_name', 'customer_address', 'customer_phone_number',
      'contractor_first_name', 'contractor_last_name', 'contractor_phone_number', 'proposal_total',
      'proposal_notes', 'your_billing_address', 'your_billing_city', 'your_billing_state'
    ]

    tokens.each do |t|
      self.agreement.gsub!(/{{#{t}}}/, "<span class='token'>#{t}</span>")
    end

    self.agreement
  end

  def add_proposal_to_name
    self.name ||= "Unnamed Proposal"
    self.name = "#{self.name} Proposal" unless self.name.include? "Proposal"
  end
end

# == Schema Information
#
# Table name: proposal_templates
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  active          :boolean          default(TRUE)
#  agreement       :text
#  deleted_at      :datetime
#  type            :string
#
