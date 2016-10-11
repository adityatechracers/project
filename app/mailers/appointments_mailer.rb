class AppointmentsMailer < BaseMailer
  def reminder(appointment)
    mail_templated('appointment-reminder', self.class.appointment_tokens(appointment),
                   :from => self.class.organization_from_address,
                   :reply_to => self.class.organization_reply_to_address,
                   :to => appointment.job.contact.email,
                   :bcc => appointment.user.email)
  end

  def confirmation(appointment)
    mail_templated('appointment-confirmation', self.class.appointment_tokens(appointment),
                   :from => self.class.organization_from_address,
                   :reply_to => self.class.organization_reply_to_address,
                   :to => appointment.job.contact.email,
                   :bcc => appointment.user.email)
  end

  def self.appointment_tokens(appointment)
    org = appointment.organization
    {
      'appointment_start_time' => I18n.l(appointment.start_datetime),
      'appointment_end_time' => I18n.l(appointment.end_datetime),
      'appointment_holder' => appointment.user.name,
      'prospect_first_name' => appointment.job.contact.first_name,
      'prospect_last_name' => appointment.job.contact.last_name,
      'your_billing_address' => org.address,
      'your_billing_city' => org.city,
      'your_billing_state' => org.region,
      'organization_name' => org.name
    }
  end
end
