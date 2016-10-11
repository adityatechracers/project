FactoryGirl.define do
  factory :job do
    title            { Faker::HipsterIpsum.words(3).join ' ' }
    contact          { |j| j.association(:contact, :organization_id => j.organization_id) }
    organization_id  { Organization.count > 0 ? Organization.last.id : nil }
    state            'Job'

    trait :lead do
      state 'Lead'
    end

    trait :completed do
      state 'Completed'
    end

    trait :with_accepted_proposal do
      after(:create) do |job|
        FactoryGirl.create(:proposal, :job_id => job.id, :proposal_state => 'Accepted', :organization_id => job.organization_id)
      end
    end
  end
end
