FactoryGirl.define do
  factory :timecard do
    organization_id            1
    user_id                    { Organization.find(organization_id).users.sample.id }
    start_datetime             { Time.zone.now - 1.day }
    end_datetime               { start_datetime + 8.hours }
    notes                      { Faker::HipsterIpsum.paragraph }

    trait :with_job do
      job do |t|
        FactoryGirl.create(:job, :with_accepted_proposal, :organization_id => t.organization_id)
      end
    end
  end
end
