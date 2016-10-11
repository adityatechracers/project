module Manage
  class EmailTemplatesController < BaseController
    load_and_authorize_resource

    def update
      if @email_template.update_attributes params[:email_template]
        redirect_to manage_email_templates_path, notice: "The email template has been updated"
      else
        render :edit
      end
    end

    def index
      @email_templates = @email_templates.where(lang: current_user.organization.language)
      # removing job feedback template as the feature was disabled.
      job_feedback = "job-client-feedback-request"
      @email_templates = @email_templates.where("name != ?", job_feedback)
      @email_templates = EmailTemplate.template_by_category(@email_templates)
    end

    def restore
      email_template = PaperTrail::Version.find(params[:version_id]).reify
      if email_template.present? && email_template.without_versioning(:save)
        redirect_to edit_manage_email_template_path(email_template), notice: "The version has been restored"
      else
        redirect_to manage_email_templates_path, flash: {error: "The version could not be restored"}
      end
    end

    def test
      BaseMailer.mail_templated(@email_template.name, {}, {to: current_user.email, from: BaseMailer.organization_from_address}).deliver
      if EmailTemplate.template_enabled?(@email_template.name)
        redirect_to :back, flash: {success: "We've sent a test email to #{current_user.email}"}
      else
        redirect_to :back, flash: {alert: "Template is not enabled"}
      end
    end

    def toggle
      if @email_template.update_attributes(enabled: !@email_template.enabled)
        redirect_to :back, flash: {success: "The email template has been #{!@email_template.enabled ? "disabled" : "enabled"}"}
      end
    end
  end
end
