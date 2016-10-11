require 'spec_helper'

describe 'web embed form', :js => true do
  it 'allows a user to schedule an appointment from the embedded form' do
    owner = create :user, :owner
    org = owner.organization
    org.update_attributes(:embed_help_text => "Here's some help", :embed_thank_you => 'Thanks a million')

    # Create an appointment using the current time in the organization's TZ
    time = nil
    Time.use_zone(org.time_zone) { time = Time.zone.now }
    appointment = create :appointment, :organization_id => org.id, :user_id => owner.id,
      :start_datetime => time, :end_datetime => time + 2.hours

    # Navigate to the embedded page and select the appointment slot
    visit "/leads/embed?org=#{org.guid}&lead_form=1&appointment_form=1"
    sleep(5) # Need to wait for the events to be fetched

    find('div.fc-title', :text => 'Available appointment slot').click
    page.should have_content("Book an appointment for Today at #{time.strftime('%-l:%M%p')}")
    page.should have_content("Here's some help")

    within('#embed_schedule_form') do
      fill_in 'First name', :with => 'Buster'
      fill_in 'Last name', :with => 'Bluth'
      fill_in 'Phone', :with => '1234568910'
      fill_in 'Email', :with => 'buster.bluth@bluthcompany.com'
      fill_in 'contact_address', :with => '1234 Main St.'
      fill_in 'contact_address2', :with => 'Suite 42'
      fill_in 'Zip', :with => '123456'
      fill_in 'Project details, questions, or comments', :with => "I'd like to build a house"
      click_on 'Schedule Appointment'
    end

    # FIXME
    #sleep(5)
    # page.should have_content("Thanks a million")

    # Should create a contact
    # FIXME
    #contact = Contact.where(organization_id: org.id, email: 'buster.bluth@bluthcompany.com').count.should eq(1)

    # Should create a job (as a lead)
    # FIXME
    # job = Job.where(:organization_id => org.id, :contact_id => contact.id).first
    # job.should_not be_nil
    # job.state.should == 'Lead'

    # Should send some sort of notification
    # TODO
  end
end
