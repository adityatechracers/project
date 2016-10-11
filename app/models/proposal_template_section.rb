class ProposalTemplateSection < ActiveRecord::Base
  attr_accessible :background_color, :default_description, :foreground_color, :name, :position, :proposal_template_id, :show_include_exclude_options, :proposal_template_items_attributes

  has_paper_trail
  belongs_to :proposal_template
  has_many :item_templates, :class_name => 'ProposalTemplateItem'
  has_many :responses, :class_name => "ProposalSectionResponse"

  before_save :set_position

  accepts_nested_attributes_for :item_templates
  acts_as_list :scope => :proposal_template

  default_scope order(:position)

  def items
    self.item_templates
  end

  private

  def set_position
    self.position ||= self.proposal_template.section_templates.not_deleted.count + 1
    insert_at(self.position)
  end
end

# == Schema Information
#
# Table name: proposal_template_sections
#
#  id                           :integer          not null, primary key
#  name                         :string(255)
#  default_description          :text
#  proposal_template_id         :integer
#  background_color             :string(255)
#  foreground_color             :string(255)
#  show_include_exclude_options :boolean          default(TRUE)
#  position                     :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  deleted_at                   :datetime
#
