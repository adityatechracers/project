require 'spec_helper'

describe 'user manages timecards', :js => true do
  before(:each) { ActionMailer::Base.deliveries = [] }

  it "sends a change notification when an owner alters an employee's timecard" do
    owner = log_in(create :user, :owner)
    employee = create :user, :employee, :organization_id => owner.organization.id
    timecard = create :timecard, :with_job, :organization_id => owner.organization.id, :user_id => employee.id

    visit "/jobs/timecards/#{timecard.id}/edit"
    page.should have_content 'Edit'

    new_date = (Time.now + 1.day).strftime("%-m/%-d/%Y")

    within('.edit_timecard') do
      fill_in 'End Date & Time', :with => new_date
      click_on 'Save'
    end

    ActionMailer::Base.deliveries.count.should == 2
    ActionMailer::Base.deliveries.last.body.should include(new_date)
    ActionMailer::Base.deliveries.last.body.should include(timecard.job.full_title)
    ActionMailer::Base.deliveries.last.to.should == [employee.email]
  end
end
