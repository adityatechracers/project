FactoryGirl.define do
  factory :email_template do
    name      { Faker::HipsterIpsum.sentence }
    subject   { Faker::HipsterIpsum.sentence }
    body      { Faker::HipsterIpsum.paragraph }
    enabled   true
    lang      'en'
  end
end
