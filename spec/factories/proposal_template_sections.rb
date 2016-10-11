FactoryGirl.define do
  factory :proposal_template_section do
    name                         { Faker::HipsterIpsum.word }
    default_description          { Faker::HipsterIpsum.sentence }
    background_color             '#fff000'
    foreground_color             '#fff'
    show_include_exclude_options true
  end
end
