FactoryGirl.define do
  factory :quote do
    quote     { Faker::HipsterIpsum.sentence }
    author    { Faker::Name.name }
  end
end
