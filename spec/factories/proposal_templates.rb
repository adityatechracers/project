FactoryGirl.define do
  factory :proposal_template do
    name      { Faker::HipsterIpsum.sentence }

    trait :master do
      organization_id 0
    end

    trait :with_sections do
      after(:create) do |proposal_template|
        FactoryGirl.create_list(:proposal_template_section, 5,
                                :proposal_template => proposal_template)
      end
    end
  end
end
