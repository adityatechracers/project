module Admin
  class EmailTemplatesController < BaseController
    load_and_authorize_resource

    def update
      if @email_template.update_attributes params[:email_template]
        redirect_to admin_email_templates_path, notice: "The email template has been updated"
      else
        render "edit"
      end
    end

    def index
      @selected_lang = params[:lang].in?(User::Language.collection.map(&:second)) ? params[:lang] : 'en'
      @email_templates = @email_templates
        .where(organization_id: nil, lang: @selected_lang)
      @email_templates = EmailTemplate.template_by_category(@email_templates) 
    end

    def sort_email_templates
      @ordered_ids = params[:ordered_template_ids].map(&:to_i)
      @email_templates = EmailTemplate.where('id IN (?)', @ordered_ids)
      if @email_templates.present?
        @ordered_email_templates = @ordered_ids.collect {|id| @email_templates.detect {|x| x.id == id}}
        @ordered_email_templates.each_with_index do |template, index|
          template.update_attributes(priority: index + 1)
        end
      end  
      render :nothing => true 
    end

    def restore
      email_template = PaperTrail::Version.find(params[:version_id]).reify
      if email_template.present? && email_template.without_versioning(:save)
        redirect_to edit_admin_email_template_path(email_template), notice: "The version has been restored"
      else
        redirect_to admin_email_templates_path, flash: {error: "The version could not be restored"}
      end
    end

    def test
      BaseMailer.mail_templated(@email_template.name, {}, {to: current_user.email, lang: @email_template.lang}).deliver
      redirect_to :back, flash: {success: "We've sent a test email to #{current_user.email}"}
    end

    def toggle
      if @email_template.update_attributes(enabled: !@email_template.enabled)
        redirect_to :back, flash: {
          success: "Your email template has been #{!@email_template.enabled ? "deactivated" : "reactivated"}"
        }
      end
    end
  end
end
