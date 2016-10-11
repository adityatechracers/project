require 'spec_helper'

describe 'user manages expense categories' do
  before(:each) do
    @org = create(:organization, :with_owner)
    @employee = log_in create(:user, organization: @org, can_manage_jobs: true)
  end

  let(:expense_category) do
    create(:expense_category, name: 'Paint', organization_id: @employee.organization_id)
  end

  it 'allows user to create an expense category' do
    visit '/jobs/expense_categories'
    click_on 'New Expense Category'

    within '#new_expense_category' do
      fill_in 'Name', with: 'Paint'
      click_on 'Save'
    end

    page.should have_content 'Expense category was successfully created'

    ExpenseCategory.first.should have_attributes(
      name: 'Paint',
      organization_id: @employee.organization_id
    )
  end

  it 'allows user to edit an expense category' do
    visit "/jobs/expense_categories/#{expense_category.id}/edit"

    within "#edit_expense_category_#{expense_category.id}" do
      fill_in 'Name', with: 'Wood'
      click_on 'Save'
    end

    page.should have_content 'Expense category was successfully updated'

    expense_category.reload.should have_attributes(
      name: 'Wood',
      organization_id: @employee.organization_id
    )
  end

  it 'allows user to delete an expense category', js: true do
    pending('skipping unreliable spec for now') if ENV['USER'] == 'jenkins'

    expense_category
    visit "/jobs/expense_categories"
    without_confirm_dialog do
      page.find('.icon-remove-2').click
    end

    page.should have_content 'Expense category was successfully deleted'
    ExpenseCategory.not_deleted.count.should eq(0)
  end

  it "only displays expense categories in the user's organization" do
    ActsAsTenant.with_tenant(nil) do
      create(:expense_category, name: 'Paint', organization_id: 0)
      create(:expense_category, name: 'Paint', organization_id: @employee.organization_id)
    end
    visit "/jobs/expense_categories"

    page.all('.widget-body table tbody tr').count.should eq(1)
  end
end
