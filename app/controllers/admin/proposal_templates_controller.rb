module Admin
  class ProposalTemplatesController < BaseController
    load_and_authorize_resource

    def index
      @proposal_templates = @proposal_templates.global
    end

    def edit
      @sections = @proposal_template.section_templates.includes(:item_templates)
    end

    def edit_contract
    end

    def contract
      @agreement = @proposal_template.render_sample_contract_agreement
      respond_to do |format|
        format.pdf do
          render :pdf => "#{@proposal_template.name}-contract-preview", :layout => 'pdf.html'
        end
      end
    end

    def update
      if @proposal_template.update_attributes params[:proposal_template]
        redirect_to edit_admin_proposal_template_path(@proposal_template),
          :notice => "The proposal template has been updated"
      else
        render :edit
      end
    end

    def destroy
      # TODO: delete sections?
      if Proposal.where(:proposal_template_id => params[:id]).any?
        redirect_to admin_proposal_templates_path(params[:proposal_template_id]),
          :notice => "This proposal is being used by one or more proposals"
      elsif ProposalTemplate.find(params[:id]).destroy
        redirect_to admin_proposal_templates_path(params[:proposal_template_id]),
          :notice => "The proposal template has been deleted"
      else
        redirect_to edit_admin_proposal_template_path(params[:proposal_template_id]),
          :notice => "The proposal template could not be deleted"
      end
    end

    def restore
      proposal_template = Version.find(params[:version_id]).reify
      if proposal_template.present? && proposal_template.without_versioning(:save)
        redirect_to edit_admin_proposal_template_path(proposal_template),
          :notice => "The version has been restored"
      else
        redirect_to admin_proposal_templates_path,
          :flash => {:error => "The version could not be restored"}
      end
    end

    def reorder_sections
      params[:section_positions].each do |section_id, section_position|
        ProposalTemplateSection.find(section_id).update_attributes! :position => section_position
        if params[:item_positions].has_key? section_id
          params[:item_positions][section_id].each do |item_id, item_position|
            ProposalTemplateItem.find(item_id).update_attributes! :position => item_position
          end
        end
      end
      render :text => "All changes have been saved."
    end
  end
end
