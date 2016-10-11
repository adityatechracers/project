module Admin
  class ProposalTemplateSectionsController < BaseController
    load_and_authorize_resource

    def new
      @template = ProposalTemplate.find(params[:proposal_template_id])
      @section = @proposal_template_section
      @section.position ||= @template.section_templates.count + 1
    end

    def create
      @proposal_template_section.proposal_template_id = ProposalTemplate.find(params[:proposal_template_id]).id
      if @proposal_template_section.save(params[:proposal_template_section])
        redirect_to edit_admin_proposal_template_path(params[:proposal_template_id]),
          :notice => "The proposal template section has been created"
      else
        render :edit
      end
    end

    def update
      if @proposal_template_section.update_attributes(params[:proposal_template_section])
        redirect_to edit_admin_proposal_template_path(params[:proposal_template_id]),
          :notice => "The proposal template section has been updated"
      else
        render :edit
      end
    end

    def edit
      @template = ProposalTemplate.find(params[:proposal_template_id])
      @section = @proposal_template_section
    end

    def destroy
      # TODO: delete items?
      if ProposalTemplateSection.find(params[:id]).destroy
        redirect_to edit_admin_proposal_template_path(params[:proposal_template_id]),
          :notice => "The proposal template section has been deleted"
      else
        redirect_to edit_admin_proposal_template_path(params[:proposal_template_id]),
          :notice => "The section could not be deleted"
      end
    end
  end
end
