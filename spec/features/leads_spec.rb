require 'spec_helper'

describe "lead management" do

  it "allows user to create a new lead" do
    log_in(create :user, :owner)

    visit '/leads/new'
    within('#new_contact') do
      fill_in "contact_first_name", :with => "Test"
      fill_in "contact_last_name", :with => "Contact"
      fill_in "contact_phone", :with => "(123) 123-1234"
      fill_in "contact_email", :with => "testcontact@example.com"
      fill_in "contact_address", :with => "123 Test Street"
      fill_in "contact_address2", :with => "Apartment 5"
      fill_in "contact_city", :with => "Test City"
      fill_in "contact_zip", :with => "48910"
      fill_in "contact_jobs_attributes_0_details", :with => "The Details"
      fill_in "contact_jobs_attributes_0_communications_attributes_0_note", :with => "Test communication"
      fill_in "contact_jobs_attributes_0_communications_attributes_0_datetime", :with => "9/30/2013 12:00 am"
      click_on "Save Lead"
    end

    page.should have_content "Your lead was added successfully"
    Contact.last.email.should == "testcontact@example.com"

    # Check permissions
    page.should have_content "Contact, Test"
  end

  it "allows owner to create a new lead source" do
    log_in(create :user, :owner)

    visit '/leads/sources/new'
    within('#new_lead_source') do
      fill_in "Name", :with => "Test Lead Source"
      click_on "Save"
    end

    page.should have_content "Your lead source was added successfully"
    LeadSource.last.name.should == "Test Lead Source"
  end

  describe 'multitenancy', js: true do
    it "uses multitenancy for leads", retry: 5 do
      pending('skipping unreliable spec for now') if ENV['USER'] == 'jenkins'

      log_in(create :user, :owner)

      visit '/leads/new'
      page.execute_script("$('#plan-next-comm-switch').click();")
      within('#new_contact') do
        fill_in "contact_first_name", :with => "Test"
        fill_in "contact_last_name", :with => "Contact"
        fill_in "contact_phone", :with => "(123) 123-1234"
        fill_in "contact_email", :with => "testcontact@example.com"
        fill_in "contact_address", :with => "123 Test Street"
        fill_in "contact_address2", :with => "Apartment 5"
        fill_in "contact_zip", :with => "48910"
        fill_in "contact_city", :with => "Lansing"
        fill_in "contact_jobs_attributes_0_details", :with => "Some details"
        fill_in "contact_jobs_attributes_0_communications_attributes_0_note", :with => "Test communication"
        fill_in "contact_jobs_attributes_0_communications_attributes_0_datetime", :with => "9/30/2013 12:00 am"
        page.execute_script %{$('#contact_region').html('<option value="MI">Michigan</option>')}
        select "Michigan", from: "contact_region"
        click_on "Save Lead"
      end

      page.should have_content "Your lead was added successfully"
      Contact.last.email.should == "testcontact@example.com"

      log_out and log_in(create :user, :owner)

      visit '/leads/'
      page.should_not have_content "Contact, Test"
    end
  end
end
