# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :expense_category do
    organization_id 1
    name "MyString"
  end
end
