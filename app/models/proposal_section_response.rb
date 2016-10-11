class ProposalSectionResponse < ActiveRecord::Base
  attr_accessible :description, :proposal_id, :proposal_template_section_id, :item_responses_attributes

  belongs_to :proposal
  belongs_to :template_section, :class_name => "ProposalTemplateSection", :foreign_key => "proposal_template_section_id"
  has_many :item_responses, :class_name => "ProposalItemResponse"

  accepts_nested_attributes_for :item_responses

  # # Inherit attributes from section template
  # def method_missing(sym, *args, &block)
  #   return self.template_section.send(sym, *args, &block) if self.template_section.respond_to? sym
  #   super(sym, *args, &block)
  # end
end

# == Schema Information
#
# Table name: proposal_section_responses
#
#  id                           :integer          not null, primary key
#  proposal_template_section_id :integer
#  proposal_id                  :integer
#  description                  :text
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
