FactoryGirl.define do
  factory :proposal do
    title                       { Faker::HipsterIpsum.words(3).join ' ' }
    customer_sig_printed_name   { Faker::Name.name }
    contractor_sig_printed_name { Faker::Name.name }
    proposal_state              'Active'

    before(:create) { |proposal| proposal.class.skip_callback(:save, :before, :set_state) }

    # Generating the PDF is problematic for test data
    after(:build) { |proposal| proposal.class.skip_callback(:create, :after, :email_proposal) }

    trait :with_job do
      organization
      before(:create) do |proposal|
        user = create :user, :organization_id => proposal.organization_id
        proposal.sales_person_id = user.id
        job = create :job, :organization_id => proposal.organization_id
        proposal.job_id = job.id
      end
    end

    trait :with_contractor do
      before(:create) do |proposal|
        user = create :user, :organization_id => proposal.organization_id
        proposal.contractor_id = user.id
      end
    end

    trait :with_salesperson do
      before(:create) do |proposal|
        user = create :user, :organization_id => proposal.organization_id
        proposal.sales_person_id = user.id
      end
    end

    trait :unsigned do
      customer_sig_printed_name   nil
      contractor_sig_printed_name nil
    end
  end
end
