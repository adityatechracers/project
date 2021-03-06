module Manage::ProposalTemplateItemsHelper
  def url_for_item_form(template, section, item)
    # simple_form_for doesn't seem to be able to generate urls for nested
    # resources using the :controller option
    item.new_record? ?
      manage_proposal_template_section_items_path(template, section) :
      manage_proposal_template_section_item_path(template, section, item)
  end
end
