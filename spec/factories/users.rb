FactoryGirl.define do
  factory :user do
    first_name                          { Faker::Name.first_name }
    last_name                           { Faker::Name.last_name }
    email                               { Faker::Internet.email }
    password                            'testtest'
    can_view_leads                      false
    can_manage_leads                    false
    can_view_appointments               false
    can_manage_appointments             false
    can_view_all_jobs                   false
    can_view_own_jobs                   false
    can_manage_jobs                     false
    can_view_all_proposals              false
    can_view_assigned_proposals         false
    can_manage_proposals                false
    can_be_assigned_appointments        false
    can_be_assigned_jobs                false
    admin_can_view_failing_credit_cards false
    admin_can_view_billing_history      false
    admin_can_manage_accounts           false
    admin_can_manage_trials             false
    admin_can_manage_cms                false
    admin_can_become_user               false
    admin_receives_notifications        false
    role                                'Employee'
    active                              true

    trait :inactive do
      active false
    end

    trait :employee do
      organization
    end

    trait :owner do
      role 'Owner'
      organization
    end

    trait :paid_owner do
      role 'Owner'
      association :organization, :paid
    end

    trait :admin do
      role 'Admin'
    end

    trait :all_permissions do
      can_view_leads               true
      can_manage_leads             true
      can_view_appointments        true
      can_manage_appointments      true
      can_view_all_jobs            true
      can_view_own_jobs            true
      can_manage_jobs              true
      can_view_all_proposals       true
      can_view_assigned_proposals  true
      can_manage_proposals         true
      can_be_assigned_appointments true
      can_be_assigned_jobs         true
    end
  end
end
