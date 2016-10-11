module Manage
  class ProposalTemplateSectionsController < BaseController
    load_and_authorize_resource

    def new
      @template = ProposalTemplate.find(params[:proposal_template_id])
      @section = @proposal_template_section
      @section.position ||= @template.section_templates.count + 1
      @background_color = '#2f4050'
      @foreground_color = '#FFFFFF'

    end

    def create
      @proposal_template_section.proposal_template_id = ProposalTemplate.find(params[:proposal_template_id]).id
      if @proposal_template_section.save(params[:proposal_template_section])
        redirect_to edit_manage_proposal_template_path(params[:proposal_template_id]),
          :notice => "The proposal template section has been created"
      else
        render :edit
      end
    end

    def update
      if @proposal_template_section.update_attributes(params[:proposal_template_section])
        redirect_to edit_manage_proposal_template_path(params[:proposal_template_id]),
          :notice => "The proposal template section has been updated"
      else
        render :edit
      end
    end

    def edit
      @template = ProposalTemplate.find(params[:proposal_template_id])
      @section = @proposal_template_section
      @background_color = @section.background_color
      @foreground_color = @section.foreground_color 
    end

    def destroy
      # TODO: delete items?
      if ProposalTemplateSection.find(params[:id]).destroy
        redirect_to edit_manage_proposal_template_path(params[:proposal_template_id]),
          :notice => "The proposal template section has been deleted"
      else
        redirect_to edit_manage_proposal_template_path(params[:proposal_template_id]),
          :notice => "The section could not be deleted"
      end
    end

    def restore
      proposal_template = ProposalTemplate.find(params[:proposal_template_id])
      section = proposal_template.section_templates.find(params[:id])
      section = section.versions.find(params[:version_id]).reify
  
      if section.present? && section.without_versioning(:save)
        redirect_to edit_manage_proposal_template_path(proposal_template),
          :notice => "The version has been restored"
      else
        redirect_to manage_proposal_templates_path,
          :flash => {:error => "The version could not be restored"}
      end
    end  
  end
end
