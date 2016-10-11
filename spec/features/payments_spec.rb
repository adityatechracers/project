require 'spec_helper'

describe 'user adds payments' do

  it 'allows user to create a payment' do
    employee = log_in(create :user, :employee, :can_manage_jobs => true)
    job = create :job, :users => [employee]
    visit '/jobs/payments'
    click_on 'New Payment'

    within '#new_payment' do
      select job.full_title, :from => 'payment_job_id'
      fill_in 'Amount', :with => '140.35'
      fill_in 'Date paid', :with => '6/13/2013'
      fill_in 'Notes', :with => 'some notes'
      select 'Cash', :from => 'Payment type'
      click_on 'Save Payment'
    end

    page.should have_content('The payment has been added')

    Payment.first.should have_attributes(
      amount: 140.35,
      date_paid: Date.parse('6/13/2013'),
      notes: 'some notes',
      payment_type: 'Cash'
    )
  end
end
