require 'spec_helper'

describe 'user manages expenses' do

  before(:each) do
    @org = create(:organization, :with_owner)
    @employee = log_in create(:user, organization: @org, can_manage_jobs: true)
    @job = create :job, users: [@employee]
    @category = create :expense_category, name: 'Tools', organization_id: @employee.organization_id
  end

  let(:expense) do
    create(:expense, amount: 150.25, date_of_expense: Date.today, job: @job,
           user: @employee, organization_id: @employee.organization_id)
  end

  it 'allows user to create an expense' do
    visit '/jobs/expenses'
    click_on 'New Expense'

    within '#new_expense' do
      select @job.full_title, from: 'expense_job_id'
      fill_in 'Amount', with: '140.35'
      select 'Tools', from: 'expense_expense_category_id'
      fill_in 'Date of expense', with: '6/13/2013'
      fill_in 'Description', with: 'Bought some tools'
      click_on 'Save Expense'
    end

    page.should have_content 'The expense has been added'

    Expense.first.should have_attributes(
      job_id: @job.id,
      expense_category_id: @category.id,
      amount: 140.35,
      date_of_expense: Date.new(2013, 6, 13),
      description: 'Bought some tools',
      user_id: @employee.id
    )
  end

  it 'allows user to edit an expense' do
    visit "/jobs/expenses/#{expense.id}/edit"

    within "#edit_expense_#{expense.id}" do
      fill_in 'Amount', with: '150.25'
      fill_in 'Date of expense', with: '6/13/2013'
      click_on 'Save Expense'
    end

    page.should have_content 'The expense has been updated'

    expense.reload.should have_attributes(
      job_id: @job.id,
      expense_category_id: nil,
      amount: 150.25,
      date_of_expense: Date.new(2013, 6, 13),
      user_id: @employee.id
    )
  end

  it 'allows user to delete an expense', js: true do
    pending('skipping unreliable spec for now') if ENV['USER'] == 'jenkins'

    expense
    visit "/jobs/expenses"
    without_confirm_dialog do
      page.find('.icon-remove-2').click
    end

    page.should have_content 'The expense has been deleted'
    Expense.not_deleted.count.should eq(0)
  end
end
