FactoryGirl.define do
  factory :appointment do
    organization_id            1
    user_id                    { Organization.find(organization_id).users.sample.id }
    start_datetime             { Time.at(rand * ((Time.zone.now.to_f + 3.5.days.to_f) - (Time.zone.now.to_f - 3.5.days.to_f)) +
                                         (Time.zone.now.to_f - 3.5.days.to_f)).to_datetime }
    end_datetime               { (start_datetime + 2.hours).to_datetime }
    notes                      { Faker::HipsterIpsum.paragraph }
    email_before_appointment   true
    sent_reminder              false

    trait :with_job do
      after(:create) do |apt|
        job = FactoryGirl.create(:job, :organization_id => apt.organization_id)
        apt.update_attribute(:job_id, job.id)
      end
    end
  end
end
