class OrganizationsMailer < BaseMailer
  def trial_2_day_follow_up(organization)
    system_mail_templated('trial-2-day-follow-up', tokens(organization),
                          to: organization.owner.email, lang: organization.language)
  end

  def trial_7_day_follow_up(organization)
    system_mail_templated('trial-7-day-follow-up', tokens(organization),
                          to: organization.owner.email, lang: organization.language)
  end

  def trial_10_day_follow_up(organization)
    system_mail_templated('trial-10-day-follow-up', tokens(organization),
                          to: organization.owner.email, lang: organization.language)
  end

  def trial_expiration_notice(organization)
    system_mail_templated('trial-expiration-notice', tokens(organization),
                          to: organization.owner.email, lang: organization.language)
  end

  def active_1_month_follow_up(organization)
    system_mail_templated('active-1-month-follow-up', tokens(organization),
                          to: organization.owner.email, lang: organization.language)
  end

  def expired_7_day_follow_up(organization)
    system_mail_templated('expired-7-day-follow-up', tokens(organization),
                          to: organization.owner.email, lang: organization.language)
  end

  def expired_1_month_follow_up(organization)
    system_mail_templated('expired-1-month-follow-up', tokens(organization),
                          to: organization.owner.email, lang: organization.language)
  end

  def email_parse_error(organization, email_body)
    @organization = organization
    @email_body = email_body
    if @organization.email.present?
      mail(to: @organization.email, subject: 'CorkCRM: Mail Parsing')
    else
      mail(to: @organization.owner.email, subject: 'CorkCRM: Mail Parsing') 
    end
  end

   def email_parse_success(organization, email_body)
    @organization = organization
    @email_body = email_body
    if @organization.email.present?
      mail(to: @organization.email, subject: 'CorkCRM: Mail Parsing')
    else
      mail(to: @organization.owner.email, subject: 'CorkCRM: Mail Parsing') 
    end
  end

  private

  def tokens(organization)
    {
      'organization_name' => organization.name,
      'owner_first_name' => organization.owner.first_name,
      'owner_last_name' => organization.owner.last_name,
    }
  end
end
