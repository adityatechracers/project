# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :google_event do
    event_id "MyText"
    title "MyString"
    start_datetime "2016-06-24 04:31:49"
    end_datetime "2016-06-24 04:31:49"
    status "MyString"
    description "MyText"
    calendar "MyString"
    user nil
  end
end
