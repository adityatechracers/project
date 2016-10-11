require 'spec_helper'

describe "contact management", js: true do

  it "creates a contact", retry: 5 do
    org = create(:organization, :with_owner)
    log_in_with(org.owner.email, 'testtest')
    visit "/contacts/new"
    within("#new_contact") do
      fill_in "contact_first_name", :with => Faker::Name.first_name
      fill_in "contact_last_name", :with => Faker::Name.last_name
      fill_in "Phone", :with => Faker::PhoneNumber.phone_number
      fill_in "Email", :with => Faker::Internet.email
      fill_in "contact_address", :with => Faker::Address.street_address
      fill_in "contact_address2", :with => Faker::Address.secondary_address
      fill_in "contact_zip", :with => "48910"
      fill_in "contact_city", :with => "Lansing"
      page.execute_script %{$('#contact_region').html('<option value="MI">Michigan</option>')}
      select "Michigan", :from => "contact_region"
      click_on "Save"
    end
    page.should have_content "Your contact was added successfully"

    log_out
  end
end
