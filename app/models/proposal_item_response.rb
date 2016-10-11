class ProposalItemResponse < ActiveRecord::Base
  attr_accessible :name, :include_exclude_option, :notes, :proposal_section_response_id, :proposal_template_item_id

  belongs_to :section_response, :class_name => "ProposalSectionResponse", :foreign_key => "proposal_section_response_id"
  belongs_to :template_item, :class_name => "ProposalTemplateItem", :foreign_key => "proposal_template_item_id"

  validates_length_of :name, :maximum => 255

  default_scope ->{ includes(:template_item).order('proposal_template_items.position') }

  def section
    self.section_response
  end
end

# == Schema Information
#
# Table name: proposal_item_responses
#
#  id                           :integer          not null, primary key
#  proposal_template_item_id    :integer
#  proposal_section_response_id :integer
#  include_exclude_option       :string(255)
#  notes                        :text
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  name                         :string(255)
#
