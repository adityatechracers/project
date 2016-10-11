User.seed_once(:email,
  {
    first_name: 'Admin',
    last_name: 'User',
    email: 'marjan@cognitelabs.com',
    password: 'cognitelabs', # should be changed after seed
    role: 'Admin',
    super: true,
    admin_can_view_failing_credit_cards: true,
    admin_can_view_billing_history: true,
    admin_can_manage_accounts: true,
    admin_can_manage_trials: true,
    admin_can_manage_cms: true,
    admin_can_become_user: true,
    admin_receives_notifications: true
  },
  {
    first_name: 'Michael',
    last_name: 'Henry',
    email: 'michaelhenry91+admin@gmail.com',
    password: 'corkcrm13', # should be changed after seed
    role: 'Admin',
    super: true,
    admin_can_view_failing_credit_cards: true,
    admin_can_view_billing_history: true,
    admin_can_manage_accounts: true,
    admin_can_manage_trials: true,
    admin_can_manage_cms: true,
    admin_can_become_user: true,
    admin_receives_notifications: true
  }
)
