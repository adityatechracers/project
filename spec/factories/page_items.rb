# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page_item do
    name "MyString"
    page_id 1
    content "MyText"
  end
end
