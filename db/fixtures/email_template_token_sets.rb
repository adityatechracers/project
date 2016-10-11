EmailTemplateTokenSet.seed(:template_name,
  {
    template_name: 'welcome',
    available_tokens: ['user_first_name', 'user_last_name', 'organization_name']
  },
  {
    template_name: 'trial-2-day-follow-up',
    available_tokens: ['owner_first_name', 'owner_last_name', 'organization.name']
  },
  {
    template_name: 'trial-7-day-follow-up',
    available_tokens: ['owner_first_name', 'owner_last_name', 'organization.name']
  },
  {
    template_name: 'trial-10-day-follow-up',
    available_tokens: ['owner_first_name', 'owner_last_name', 'organization.name']
  },
  {
    template_name: 'trial-expiration-notice',
    available_tokens: ['owner_first_name', 'owner_last_name', 'organization.name']
  },
  {
    template_name: 'active-1-month-follow-up',
    available_tokens: ['owner_first_name', 'owner_last_name', 'organization.name']
  },
  {
    template_name: 'expired-7-day-follow-up',
    available_tokens: ['owner_first_name', 'owner_last_name', 'organization.name']
  },
  {
    template_name: 'expired-1-month-follow-up',
    available_tokens: ['owner_first_name', 'owner_last_name', 'organization.name']
  },
  {
    template_name: 'lead-welcome',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state'
    ]
  },
  {
    template_name: 'lead-added-via-embed',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state'
    ]
  },
  {
    template_name: 'proposal-accepted',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'proposal_number',
      'proposal_url',
      'contract_portal_url',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name'
    ]
  },
  {
    template_name: 'proposal-issued',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'proposal_number',
      'proposal_url',
      'contract_portal_url',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name'
    ]
  },
  {
    template_name: 'proposal-issued-2-day-reminder',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'proposal_number',
      'proposal_url',
      'contract_portal_url',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name'
    ]
  },
  {
    template_name: 'proposal-issued-1-week-reminder',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'proposal_number',
      'proposal_url',
      'contract_portal_url',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name'
    ]
  },
  {
    template_name: 'proposal-issued-1-month-reminder',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'proposal_number',
      'proposal_url',
      'contract_portal_url',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name'
    ]
  },
  {
    template_name: 'proposal-issued-2-month-reminder',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'proposal_number',
      'proposal_url',
      'contract_portal_url',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name'
    ]
  },
  {
    template_name: 'proposal-issued-3-month-reminder',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'proposal_number',
      'proposal_url',
      'contract_portal_url',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name'
    ]
  },
  {
    template_name: 'proposal-contract-signed-notification',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'proposal_number',
      'proposal_url',
      'contract_portal_url',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name'
    ]
  },
  {
    template_name: 'proposal-contract-signed-confirmation',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'proposal_number',
      'proposal_url',
      'contract_portal_url',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name'
    ]
  },
  {
    template_name: 'proposal-change-order-notification',
    available_tokens: [
      'change_order_summary',
      'previous_proposal_amount',
      'previous_budgeted_hours',
      'previous_expected_start_date',
      'previous_expected_end_date',
      'current_proposal_amount',
      'current_budgeted_hours',
      'current_expected_start_date',
      'current_expected_end_date',
      'prospect_first_name',
      'prospect_last_name',
      'proposal_number',
      'proposal_url',
      'contract_portal_url',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name'
    ]
  },
  {
    template_name: 'appointment-reminder',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'appointment_holder',
      'appointment_start_time',
      'appointment_end_time',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name'
    ],
  },
  {
    template_name: 'appointment-confirmation',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'appointment_holder',
      'appointment_start_time',
      'appointment_end_time',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name'
    ]
  },
  {
    template_name: 'appointment-2-day-follow-up',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name',
      'contractor_phone_number',
      'contractor_name'
    ]
  },
  {
    template_name: 'appointment-7-day-follow-up',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name',
      'contractor_phone_number',
      'contractor_name'
    ]
  },
  {
    template_name: 'job-complete',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name',
      'contractor_phone_number',
      'contractor_name',
      'feedback_portal_url'
    ]
  },
  {
    template_name: 'job-complete-1-month-follow-up',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name',
      'contractor_phone_number',
      'contractor_name',
      'feedback_portal_url'
    ]
  },
  {
    template_name: 'job-client-feedback-request',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name',
      'contractor_phone_number',
      'contractor_name',
      'feedback_portal_url'
    ]
  },
  {
    template_name: 'job-scheduled-1-day-reminder',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name',
      'contractor_phone_number',
      'contractor_name',
      'feedback_portal_url',
      'scheduled_start_time',
      'scheduled_end_time',
      'scheduled_start_date',
      'scheduled_end_date'
    ]
  },
  {
    template_name: 'job-scheduled-3-day-reminder',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name',
      'contractor_phone_number',
      'contractor_name',
      'feedback_portal_url',
      'scheduled_start_time',
      'scheduled_end_time',
      'scheduled_start_date',
      'scheduled_end_date'

    ]
  },
  {
    template_name: 'job-scheduled-7-day-reminder',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name',
      'contractor_phone_number',
      'contractor_name',
      'feedback_portal_url',
      'scheduled_start_time',
      'scheduled_end_time',
      'scheduled_start_date',
      'scheduled_end_date'

    ]
  },
  {
    template_name: 'job-scheduled-notification',
    available_tokens: [
      'prospect_first_name',
      'prospect_last_name',
      'your_billing_address',
      'your_billing_city',
      'your_billing_state',
      'organization_name',
      'contractor_phone_number',
      'contractor_name',
      'feedback_portal_url',
      'scheduled_start_time',
      'scheduled_end_time',
      'scheduled_start_date',
      'scheduled_end_date'

    ]
  },
  {
    template_name: 'cancelled-paid-account',
    available_tokens: ['organization_name']
  },
  {
    template_name: 'stripe-invoice-payment-failed',
    available_tokens: ['organization_name']
  },
  {
    template_name: 'stripe-invoice-payment-successful',
    available_tokens: ['organization_name', 'charge_total']
  },
  {
    template_name: 'stripe-charge-successful',
    available_tokens: ['organization_name', 'charge_total']
  },
  {
    template_name: 'stripe-charge-failed',
    available_tokens: ['organization_name', 'charge_total']
  },
  {
    template_name: 'stripe-charge-dispute-created',
    available_tokens: ['organization_name']
  },
  {
    template_name: 'stripe-subscription-created',
    available_tokens: ['organization_name', 'plan_name']
  },
  {
    template_name: 'stripe-subscription-updated',
    available_tokens: ['organization_name', 'plan_name']
  },
  {
    template_name: 'stripe-subscription-deleted',
    available_tokens: ['organization_name']
  }
)
