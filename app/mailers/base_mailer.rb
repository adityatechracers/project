class BaseMailer < ActionMailer::Base
  include ActionView::Helpers::SanitizeHelper

  layout :choose_layout

  DISPLAY_NAME_STRIP = /[^0-9A-Za-z&\- ]/

  def choose_layout
    # When sending mail via cron jobs, we need to be careful to set the current
    # tenant, otherwise they are sent as CorkCRM.
    return 'organization_mailer' if ActsAsTenant.current_tenant.present?
    'corkcrm_mailer'
  end

  def self.admin_email_addresses
    User.unscoped.where(:role => 'Admin')
      .where(:admin_receives_notifications => true)
      .map(&:email)
  end

  def self.organization_from_address
    return 'Notifications <notifications@corkcrm.com>' if organization.nil?
    cleaned_org_name = organization.name.gsub(DISPLAY_NAME_STRIP, '')
    "\"#{cleaned_org_name}\" <#{organization.name.parameterize}.#{organization.id}@corkcrm.com>"
  end

  def self.organization_reply_to_address
    return '' if organization.nil? || organization.owner.nil?
    cleaned_owner_name = organization.owner.name.gsub(DISPLAY_NAME_STRIP, '')
    "\"#{cleaned_owner_name}\" <#{organization.owner.email}>"
  end

  def mail(*args)
    message = super(*args)
    logger = Logger.new('log/emails.log')
    logger.info message.to_yaml
    message
  end

  def system_mail_templated(template_name, *args)
    ActsAsTenant.with_tenant(nil) do
      mail_templated(template_name, *args)
    end
  end

  def system_mail_templated!(template_name, *args)
    ActsAsTenant.with_tenant(nil) do
      if organization
        cc_mail = EmailTemplate.where(name: template_name).where(lang: I18n.locale).where(organization_id: organization.id).first.mail_to_cc
        if (cc_mail != nil) && (cc_mail != "")
          cc_hash = { :cc => cc_mail}
          temp_args = *args
          temp_args[1] = temp_args[1].merge(cc_hash)
          mail_templated!(template_name, *temp_args)
        else
          mail_templated!(template_name, *args)
        end
      else
        mail_templated!(template_name, *args)
      end
    end
  end

  def mail_templated(template_name, *args)
    return false unless EmailTemplate.template_enabled?(template_name)
    if organization
      cc_mail = EmailTemplate.where(name: template_name).where(lang: I18n.locale).where(organization_id: organization.id).first.mail_to_cc
      if (cc_mail != nil) && (cc_mail != "")
        cc_hash = { :cc => cc_mail}
        temp_args = *args
        temp_args[1] = temp_args[1].merge(cc_hash)
        mail_templated!(template_name, *temp_args)
      else
        mail_templated!(template_name, *args)
      end
    else
      mail_templated!(template_name, *args)
    end
  end

  # This method will throw an error if the template_name does not exist or is
  # not enabled. Use `mail_templated` to avoid the error.
  def mail_templated!(template_name, tokens, options = {})
    options[:subject] = EmailTemplate.render_subject(template_name, tokens, options)
    options_body = options[:body].present? ? options[:body] : ""
    @body = EmailTemplate.render_body(template_name, tokens, options) 
    @body = @body.present? ? @body : options_body
    @organization = organization # May be nil
    mail(options) do |format|
      format.html { render 'base_mailer/mail_templated' }
    end
  end
  
  protected   
  def templated_enabled? template
    EmailTemplate.template_enabled?(template)
  end  

  private

  def organization
    self.class.organization
  end

  def self.organization
    ActsAsTenant.current_tenant # May be nil
  end
end
