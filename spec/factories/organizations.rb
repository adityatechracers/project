FactoryGirl.define do
  factory :organization do
    name              { Faker::Company.name }
    stripe_plan_id    { ['Free', 'Bronze', 'Silver', 'Gold', 'Platinum'].sample }
    active            true
    trial_start_date  { Time.zone.now }
    time_zone         { ActiveSupport::TimeZone.zones_map.keys.sample } # Keep things interesting

    trait :trial do
      stripe_plan_id 'Free'
    end

    trait :paid do
      after(:create) do |org|
        org.update_attribute(:stripe_plan_id, ['Bronze', 'Silver', 'Gold', 'Platinum'].sample)
      end
    end

    trait :with_owner do
      after(:create) do |org|
        FactoryGirl.create(:user, role: 'Owner', :organization_id => org.id)
      end
    end
  end
end
