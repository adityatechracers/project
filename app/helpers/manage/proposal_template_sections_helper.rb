module Manage::ProposalTemplateSectionsHelper
  def url_for_section_form(template, section)
    # simple_form_for doesn't seem to be able to generate urls for nested
    # resources using the :controller option
    section.new_record? ?
      manage_proposal_template_sections_path(template) :
      manage_proposal_template_section_path(template, section)
  end
end
