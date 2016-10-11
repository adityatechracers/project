class SubscriptionsMailer < BaseMailer
  default from: "subscriptions@corkcrm.com"
  layout 'corkcrm_mailer'

  def cancelled_paid_account(organization)
    tokens = { 'organization_name' => organization.name }
    system_mail_templated!('cancelled-paid-account', tokens,
                           to: organization.owner.email, lang: organization.language)
  end

  def invoice_payment_failed(organization)
    tokens = { 'organization_name' => organization.name }
    system_mail_templated!('stripe-invoice-payment-failed', tokens,
                           to: organization.owner.email, lang: organization.language)
  end

  def invoice_payment_successful(organization, total)
    tokens = {
      'organization_name' => organization.name,
      'charge_total' => total.to_i / 100
    }
    system_mail_templated!('stripe-invoice-payment-successful', tokens,
                           to: organization.owner.email, lang: organization.language)
  end

  def charge_failed(organization)
    tokens = { 'organization_name' => organization.name }
    system_mail_templated('stripe-charge-failed', tokens,
                          to: organization.owner.email, lang: organization.language)
  end

  def charge_successful(organization, total)
    tokens = {
      'organization_name' => organization.name,
      'charge_total' => total.to_i / 100
    }
    system_mail_templated('stripe-charge-successful', tokens,
                          to: organization.owner.email, lang: organization.language)
  end

  def charge_dispute_created(organization)
    tokens = { 'organization_name' => organization.name }
    system_mail_templated!('stripe-charge-dispute-created', tokens, to: self.class.admin_email_addresses)
  end

  def subscription_created(organization, plan)
    tokens = {
      'organization_name' => organization.name,
      'plan_name' => plan
    }
    system_mail_templated!('stripe-subscription-created', tokens,
                           to: organization.owner.email, lang: organization.language)
  end

  def subscription_updated(organization, plan)
    tokens = {
      'organization_name' => organization.name,
      'plan_name' => plan
    }
    system_mail_templated!('stripe-subscription-updated', tokens,
                           to: organization.owner.email, lang: organization.language)
  end

  def subscription_deleted(organization)
    tokens = {
      'organization_name' => organization.name,
      'plan_name' => 'Free'
    }
    system_mail_templated!('stripe-subscription-deleted', tokens,
                           to: organization.owner.email, lang: organization.language)
  end

  def failed_payment_reminder(organization, day_count)
    system_mail_templated!('failed-payment-reminder', {'days' => (7-day_count)},
                          to: organization.owner.email, lang: organization.language)
  end
end
