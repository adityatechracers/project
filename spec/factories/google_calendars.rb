# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :google_calendar do
    calendar_id "MyString"
    title "MyString"
    time_zone "MyString"
    access_role "MyString"
    primary false
    user nil
  end
end
