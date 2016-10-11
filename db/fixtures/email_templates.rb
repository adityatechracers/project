# These will be seeded once. This task runs on each deploy, so additional
# templates can be added as needed. Each is created if an email template with
# the name, master setting and language is not found.
#
# Because we're now supporting multiple languages, the descriptions should be
# copied to the locale files under the `owner.email_templates.descriptions`
# key. They are only here for reference now.
#
# We'll create a set of templates for each language. Organizations will use the
# template set matching the org owner's configured language. Initially they'll
# all be in English, but the site admins will be able to fill in the
# translations.
[User::Language::ENGLISH, User::Language::FRENCH_CANADA].each do |lang|
  EmailTemplate.seed_once(:name, :master, :lang,
    {
      name: 'welcome',
      description: 'Sent to CorkCRM customer upon account creation',
      subject: 'Welcome to CorkCRM',
      body: 'Hi {{user_first_name}} {{user_last_name}}! Welcome to CorkCRM.',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'trial-2-day-follow-up',
      description: 'Sent to CorkCRM customer 2 days into the trial period',
      subject: 'Get started with CorkCRM',
      body: 'Edit this content (trial 2 day)',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'trial-7-day-follow-up',
      description: 'Sent to CorkCRM customer 7 days into the trial period',
      subject: 'Edit this subject (trial 7 day)',
      body: 'Edit this content',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'trial-10-day-follow-up',
      description: 'Sent to CorkCRM customer 10 days into the trial period',
      subject: 'Edit this subject (trial 10 day)',
      body: 'Edit this content',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'trial-expiration-notice',
      description: 'Sent to CorkCRM customer on the last day of the trial period',
      subject: 'Edit this subject (trial expired)',
      body: 'Edit this content',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'active-1-month-follow-up',
      description: 'Sent to active CorkCRM customer 1 month after account creation',
      subject: 'Edit this subject (active 1 month)',
      body: 'Edit this content',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'expired-7-day-follow-up',
      description: 'Sent to CorkCRM customer 7 days after trial expiration',
      subject: 'Edit this subject (expired 7 day)',
      body: 'Edit this content',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'expired-1-month-follow-up',
      description: 'Sent to CorkCRM customer 1 month after trial expiration',
      subject: 'Edit this subject (expired 1 month)',
      body: 'Edit this content',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'lead-welcome',
      description: 'Sent to lead contact after a lead is created',
      subject: 'Edit this subject',
      body: 'Edit this content',
      master: true,
      enabled: true,
      lang: lang
    },
    {
      name: 'lead-added-via-embed',
      description: 'Sent to organization owner after a lead is added via the embeddable form',
      subject: 'Edit this subject',
      body: 'Edit this content',
      master: true,
      enabled: true,
      lang: lang
    },
    {
      name: 'proposal-accepted',
      description: 'Sent to client, contractor and salesperson with PDF attachment after a proposal is accepted',
      subject: "Here's a copy of your signed proposal",
      body: 'Edit this content',
      master: true,
      enabled: true,
      lang: lang
    },
    {
      name: 'proposal-issued',
      description: 'Sent to client, contractor and salesperson with PDF attachment when a proposal is issued',
      subject: 'Your proposal is ready',
      body: 'Edit this content',
      master: true,
      enabled: true,
      lang: lang
    },
    {
      name: 'proposal-issued-2-day-reminder',
      description: 'Sent to client 2 days after a proposal is created, if it is still active',
      subject: 'Edit this subject (active proposal 2 day reminder)',
      body: 'Edit this content',
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'proposal-issued-1-week-reminder',
      description: 'Sent to client 1 week after a proposal is issued, if it is still active',
      subject: 'Edit this subject (active proposal 1 week reminder)',
      body: 'Edit this content',
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'proposal-issued-1-month-reminder',
      description: 'Sent to client 1 month after a proposal is issued, if it is still active',
      subject: 'Edit this subject (active proposal 1 month reminder)',
      body: 'Edit this content',
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'proposal-issued-2-month-reminder',
      description: 'Sent to client 2 months after a proposal is issued, if it is still active',
      subject: 'Edit this subject (active proposal 2 month reminder)',
      body: 'Edit this content',
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'proposal-issued-3-month-reminder',
      description: 'Sent to client 3 months after a proposal is issued, if it is still active',
      subject: 'Edit this subject (active proposal 3 month reminder)',
      body: 'Edit this content',
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'proposal-contract-signed-notification',
      description: 'Sent to contractor after a proposal is signed by the client',
      subject: '{{ prospect_first_name }} has just signed proposal #{{ proposal_number }}',
      body: '{{ prospect_first_name }} has just signed proposal #{{ proposal_number }}',
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'proposal-contract-signed-confirmation',
      description: 'Sent to client after he or she has signed a proposal',
      subject: 'Thanks for signing proposal #{{ proposal_number }}!',
      body: 'Edit this content',
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'proposal-change-order-notification',
      description: 'Sent to client and sales person after a change order is applied to a proposal',
      subject: 'A new change order has been created for proposal #{{ proposal_number }}',
      body: 'Edit this content',
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'appointment-reminder',
      description: 'Sent to client 48 hours before a scheduled appointment',
      subject: 'Edit this subject',
      subject: 'Appointment Reminder',
      body: 'This is reminder that you have an appointment with {{appointment_holder}}
             from {{appointment_start_time}} to {{appointment_end_time}}',
      master: true,
      enabled: true,
      lang: lang
    },
    {
      name: 'appointment-confirmation',
      description: "Sent to your organization's appointment holder when an appointment is scheduled (or rescheduled)",
      subject: 'Edit this subject',
      subject: 'Appointment Confirmation',
      body: 'This confirms your appointment with {{prospect_first_name}} {{prospect_last_name}}
             from {{appointment_start_time}} to {{appointment_end_time}}',
      master: true,
      enabled: true,
      lang: lang
    },
    {
      name: 'appointment-2-day-follow-up',
      description: "Sent to client 2 days after they are added to the system if no appointment has been scheduled",
      subject: 'Reminder to schedule appointment',
      body: "Edit this content",
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'appointment-7-day-follow-up',
      description: "Sent to client 7 days after they are added to the system if no appointment has been scheduled",
      subject: 'Reminder to schedule appointment',
      body: "Edit this content",
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'job-complete',
      description: "Sent to client when a job is marked as completed",
      subject: 'Edit this subject',
      body: "Edit this content",
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'job-complete-1-month-follow-up',
      description: "Sent to client 1 month after a job is marked as completed",
      subject: 'Edit this subject',
      body: "Edit this content",
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'job-client-feedback-request',
      description: "Sent to client when the job's 'Request customer feedback' button is clicked.",
      subject: 'Let us know how we did!',
      body: "We'd appreciate any feedback on our recent work. Follow the link below to continue:<br> <a href='{{feedback_portal_url}}'>{{feedback_portal_url}}</a>.",
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'job-scheduled-1-day-reminder',
      description: "Sent to client 1 day before the scheduled start time. Note that this is sent for each schedule entry.",
      subject: 'Edit this subject',
      body: "Edit this content",
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'job-scheduled-3-day-reminder',
      description: "Sent to client 3 days before the scheduled start time. Note that this is sent for each schedule entry.",
      subject: 'Edit this subject',
      body: "Edit this content",
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'job-scheduled-7-day-reminder',
      description: "Sent to client 7 days before the scheduled start time. Note that this is sent for each schedule entry.",
      subject: 'Edit this subject',
      body: "Edit this content",
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'job-scheduled-notification',
      description: "Sent to client when a schedule entry is added or the start date changes. This email is delayed and sent at most once per hour.",
      subject: 'Edit this subject',
      body: "Edit this content",
      master: true,
      enabled: false,
      lang: lang
    },
    {
      name: 'cancelled-paid-account',
      description: 'Sent to CorkCRM administrators when a CorkCRM subscription is cancelled',
      subject: 'CorkCRM: {{organization_name}} cancelled subscription',
      body: '{{organization_name}} has cancelled their subscription.',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'stripe-invoice-payment-failed',
      description: 'Sent to CorkCRM customer when an invoice payment fails ',
      subject: 'CorkCRM: Your payment has failed',
      body: 'Edit this content',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'stripe-invoice-payment-successful',
      description: 'Sent to CorkCRM customer when an invoice payment succeeds ',
      subject: 'CorkCRM: Your payment was successful',
      body: 'This confirms your invoice payment of ${{charge_total}} was successful.',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'stripe-charge-succeeded',
      description: 'Sent to CorkCRM customer when a charge succeeds. Note that stripe-invoice-payment-successful will usually be sent too.',
      subject: 'CorkCRM: Your payment was successful',
      body: 'This confirms your payment of ${{charge_total}} was successful.',
      master: false,
      enabled: false,
      lang: lang
    },
    {
      name: 'stripe-charge-failed',
      description: 'Sent to CorkCRM customer when a charge fails. Note that stripe-invoice-payment-failed will usually be sent too.',
      subject: 'CorkCRM: Your payment failed',
      body: 'CorkCRM was unable to charge ${{charge_total}} to your credit card',
      master: false,
      enabled: false,
      lang: lang
    },
    {
      name: 'stripe-charge-dispute-created',
      description: 'Sent to CorkCRM administrators when a CorkCRM customer creates a charge dispute',
      subject: 'CorkCRM: A new charge dispute was created',
      body: 'A new charge dispute was created by {{organization_name}}.',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'stripe-subscription-created',
      description: 'Sent to CorkCRM customer when a paid subscription is created',
      subject: 'CorkCRM: Thanks for subscribing!',
      body: '{{organization_name}} is now subscribed to the {{plan_name}} plan on CorkCRM.',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'stripe-subscription-updated',
      description: 'Sent to CorkCRM customer when a paid subscription is updated (upgraded/downgraded)',
      subject: 'CorkCRM: Your subscription has been updated',
      body: '{{organization_name}} is now subscribed to the {{plan_name}} plan on CorkCRM.',
      master: false,
      enabled: true,
      lang: lang
    },
    {
      name: 'stripe-subscription-deleted',
      description: 'Sent to CorkCRM customer when a paid subscription is cancelled',
      subject: 'CorkCRM: Your subscription has been cancelled.',
      body: 'This confirms that your CorkCRM subscription has been cancelled.',
      master: false,
      enabled: true,
      lang: lang
    }
  )
end
