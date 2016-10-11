FactoryGirl.define do
  factory :contact do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email      { Faker::Internet.email }
    phone      { Faker::PhoneNumber.phone_number }
    company    { Faker::Company.name }
    address    { Faker::Address.street_address }
    zip        { Faker::AddressUS.zip_code }
    city       { Faker::Address.city }
    region     { Faker::AddressUS.state }
    country    { 'United States' }
  end
end
