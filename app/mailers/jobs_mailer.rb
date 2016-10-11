class JobsMailer < BaseMailer
  def lead_welcome(job)
    mail_templated('lead-welcome', self.class.job_tokens(job),
                   :to => job.contact.email,
                   :from => self.class.organization_from_address,
                   :reply_to => self.class.organization_reply_to_address)
  end

  def lead_added_via_embed(job)
    mail_templated('lead-added-via-embed', self.class.job_tokens(job),
                   :to => self.class.organization_reply_to_address,
                   :from => self.class.organization_from_address)
  end

  def appointment_2_day_follow_up(job)
    mail_templated('appointment-2-day-follow-up', self.class.job_tokens(job),
                   :to => job.contact.email,
                   :from => self.class.organization_from_address,
                   :reply_to => self.class.organization_reply_to_address)
  end

  def appointment_7_day_follow_up(job)
    mail_templated('appointment-7-day-follow-up', self.class.job_tokens(job),
                   :to => job.contact.email,
                   :from => self.class.organization_from_address,
                   :reply_to => self.class.organization_reply_to_address)
  end

  def job_complete(job)
    mail_templated('job-complete', self.class.job_tokens(job),
                   :to => job.contact.email,
                   :from => self.class.organization_from_address,
                   :reply_to => self.class.organization_reply_to_address)
  end

  def job_complete_1_month_follow_up(job)
    mail_templated('job-complete-1-month-follow-up', self.class.job_tokens(job),
                   :to => job.contact.email,
                   :from => self.class.organization_from_address,
                   :reply_to => self.class.organization_reply_to_address)
  end

  def job_client_feedback_request(job)
    mail_templated!('job-client-feedback-request', self.class.job_tokens(job),
                    :to => job.contact.email,
                    :from => self.class.organization_from_address,
                    :reply_to => self.class.organization_reply_to_address)
  end

  def job_feedback_notice(job, job_feedback)
    @job = job
    @job_feedback = job_feedback

    sales_people_emails = job.proposals.accepted.map { |p| p.sales_person.try(:email) }.compact
    emails = sales_people_emails.push(job.organization.owner.try(:email)).uniq
    subject = "CorkCRM: New customer feedback for #{job.full_title}"

    mail(to: emails, subject: subject) do |format|
      format.html { render layout: 'corkcrm_mailer' }
    end
  end

  # Supports the following templates:
  #
  #   job-scheduled-1-day-reminder
  #   job-scheduled-3-day-reminder
  #   job-scheduled-7-day-reminder
  #
  def job_scheduled_reminder(job, job_schedule_entry, days_from_now)
    @job = job
    @job_schedule_entry = job_schedule_entry

    tokens = self.class.scheduled_job_tokens(job, job_schedule_entry)
    mail_templated("job-scheduled-#{days_from_now}-day-reminder", tokens,
                   :to => job.contact.email,
                   :from => self.class.organization_from_address,
                   :reply_to => self.class.organization_reply_to_address)
  end

   JOB_SCHEDULED_NOTIFICATION_TEMPLATE = "job-scheduled-notification"
   
  def job_scheduled_notification_enabled?
    templated_enabled? JOB_SCHEDULED_NOTIFICATION_TEMPLATE
  end  

  def job_scheduled_notification(job, job_schedule_entry)
    @job = job
    @job_schedule_entry = job_schedule_entry

    tokens = self.class.scheduled_job_tokens(job, job_schedule_entry)
    mail_templated(JOB_SCHEDULED_NOTIFICATION_TEMPLATE, tokens,
                   :to => job.contact.email,
                   :from => self.class.organization_from_address,
                   :reply_to => self.class.organization_reply_to_address)
  end

  def self.scheduled_job_tokens(job, job_schedule_entry)
    # Add two additional tokens for the scheduled job email templates.
    timezone = job.contact.timezone
    job_tokens(job).merge(
      'scheduled_start_time' => I18n.l(timezone.time(job_schedule_entry.start_datetime)),
      'scheduled_end_time'   => I18n.l(timezone.time(job_schedule_entry.end_datetime)),
      'scheduled_start_date' => I18n.l(timezone.time(job_schedule_entry.start_datetime).to_date),
      'scheduled_end_date'   => I18n.l(timezone.time(job_schedule_entry.end_datetime).to_date)
    )
  end

  def self.job_tokens(job)
    {
      'prospect_first_name' => job.contact.first_name,
      'prospect_last_name' => job.contact.last_name,
      'your_billing_address' => job.organization.address,
      'your_billing_city' => job.organization.city,
      'your_billing_state' => job.organization.region,
      'organization_name' => job.organization.name,
      # These might not even be present, but we'll try to make them available
      'contractor_phone_number' => job.proposals.try(:last).try(:contractor).try(:phone),
      'contractor_name' => job.proposals.try(:last).try(:contractor).try(:name),
      'feedback_portal_url' => Rails.application.routes.url_helpers.feedback_portal_url(job.guid)
    }
  end
end
