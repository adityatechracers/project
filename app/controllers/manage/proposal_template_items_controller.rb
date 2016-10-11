module Manage
  class ProposalTemplateItemsController < BaseController
    load_and_authorize_resource
    before_filter :load_models

    def new
    end

    def create
      @proposal_template_item.proposal_template_section_id = @section.id
      if @proposal_template_item.save(params[:proposal_template_item])
        redirect_to edit_manage_proposal_template_path(params[:proposal_template_id]),
          notice: "The proposal template item has been created"
      else
        load_models and render :edit
      end
    end

    def update
      if @proposal_template_item.update_attributes(params[:proposal_template_item])
        redirect_to edit_manage_proposal_template_path(params[:proposal_template_id]),
          notice: "The proposal template item has been updated"
      else
        load_models and render :edit
      end
    end

    def edit
    end

    def destroy
      if ProposalTemplateItem.find(params[:id]).destroy
        redirect_to edit_manage_proposal_template_path(params[:proposal_template_id]),
          notice: "The proposal template item has been deleted"
      else
        redirect_to edit_manage_proposal_template_path(params[:proposal_template_id]),
          error: "The item could not be deleted"
      end
    end

    def restore
      proposal_template = ProposalTemplate.find(params[:proposal_template_id])
      section = proposal_template.section_templates.find(params[:section_id])
      item = section.item_templates.find(params[:id])
      item = item.versions.find(params[:version_id]).reify
  
      if item.present? && item.without_versioning(:save)
        redirect_to edit_manage_proposal_template_path(proposal_template),
          :notice => "The version has been restored"
      else
        redirect_to manage_proposal_templates_path,
          :flash => {:error => "The version could not be restored"}
      end
    end  

    protected

    def load_models
      @template = ProposalTemplate.find(params[:proposal_template_id])
      @section = ProposalTemplateSection.find(params[:section_id])
      @item = @proposal_template_item
    end
  end
end
