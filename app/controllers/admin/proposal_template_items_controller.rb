module Admin
  class ProposalTemplateItemsController < BaseController
    load_and_authorize_resource

    def new
      @template = ProposalTemplate.find(params[:proposal_template_id])
      @section = ProposalTemplateSection.find(params[:section_id])
      @item = @proposal_template_item
    end

    def create
      @proposal_template_item.proposal_template_section_id = ProposalTemplateSection.find(params[:section_id]).id
      if @proposal_template_item.save(params[:proposal_template_item])
        redirect_to edit_admin_proposal_template_path(params[:proposal_template_id]),
          :notice => "The proposal template item has been created"
      else
        render :edit
      end
    end

    def update
      if @proposal_template_item.update_attributes(params[:proposal_template_item])
        redirect_to edit_admin_proposal_template_path(params[:proposal_template_id]),
          :notice => "The proposal template item has been updated"
      else
        render :edit
      end
    end

    def edit
      @template = ProposalTemplate.find(params[:proposal_template_id])
      @section = ProposalTemplateSection.find(params[:section_id])
      @item = @proposal_template_item
    end

    def destroy
      if ProposalTemplateItem.find(params[:id]).destroy
        redirect_to edit_admin_proposal_template_path(params[:proposal_template_id]),
          :notice => "The proposal template item has been deleted"
      else
        redirect_to edit_admin_proposal_template_path(params[:proposal_template_id]),
          :notice => "The item could not be deleted"
      end
    end
  end
end
