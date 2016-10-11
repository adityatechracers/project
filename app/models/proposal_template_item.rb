class ProposalTemplateItem < ActiveRecord::Base
  attr_accessible :default_include_exclude_option, :default_note_text, :help_text, :name, :proposal_template_section_id, :position
  has_paper_trail
  belongs_to :template_section, :class_name => "ProposalTemplateSection", :foreign_key => "proposal_template_section_id"

  validates_length_of :name, :maximum => 255

  # before_save :set_position

  acts_as_list :scope => :proposal_template_section
  default_scope order("proposal_template_items.position ASC")

  def section
    self.template_section
  end

  def notes

  end

  private

  def set_position
    self.position ||= self.proposal_template.section_templates.not_deleted.count + 1
    insert_at(self.position)
  end
end

# == Schema Information
#
# Table name: proposal_template_items
#
#  id                             :integer          not null, primary key
#  name                           :string(255)
#  default_note_text              :text
#  help_text                      :string(255)
#  default_include_exclude_option :string(255)
#  proposal_template_section_id   :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  position                       :integer
#  deleted_at                     :datetime
#
