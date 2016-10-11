require 'spec_helper'

describe 'admin permissions', :js => true do

  it 'allows admin to view invoices when permitted' do
    admin = log_in(create(:user, :admin, :admin_can_view_billing_history => true))
    within('.widget') { click_on('Invoices') }
    page.should_not have_content('You do not have permission to access this area or content.')
  end

  it 'stops admin from viewing invoices when not permitted' do
    admin = log_in(create(:user, :admin))
    within('.widget') { page.should_not have_content('Invoices') }
    visit '/admin/invoices'
    page.should have_content('You do not have permission to access this area or content.')
    page.should have_content('At a glance')
  end

  it 'allows admin to view failing credit cards when permitted' do
    admin = log_in(create(:user, :admin, :admin_can_view_failing_credit_cards => true))
    within('.widget') { click_on('Failing Credit Cards') }
    visit '/admin/failing_cards'
    page.should_not have_content('You do not have permission to access this area or content.')
  end

  it 'stops admin from viewing failing credit cards when not permitted' do
    admin = log_in(create(:user, :admin))
    within('.widget') { page.should_not have_content('View failing payments') }
    visit '/admin/failing_cards'
    page.should have_content('You do not have permission to access this area or content.')
    page.should have_content('At a glance')
  end

  it 'allows admin to manage users and organizations when permitted' do
    admin = log_in(create(:user, :admin, :admin_can_manage_accounts => true))

    user = create(:user, :owner)

    within('.widget') { click_on 'Users' }
    page.should_not have_content('You do not have permission to access this area or content.')
    page.should have_content(user.email)

    visit '/admin'

    within('.widget') { click_on 'Organizations' }
    page.should_not have_content('You do not have permission to access this area or content.')
    page.should have_content(user.name)
    page.should have_content(user.organization.name)
  end

  it 'stops admin from managing users and organizations when not permitted' do
    admin = log_in(create(:user, :admin))

    user = create(:user, :owner)

    within('.widget') { page.should_not have_content('Manage user accounts within CorkCRM') }
    visit '/admin/users'
    page.should have_content('You do not have permission to access this area or content.')

    visit '/admin'

    within('.widget') { page.should_not have_content('Manage organization accounts within CorkCRM') }
    visit '/admin/organizations'
    page.should have_content('You do not have permission to access this area or content.')
  end
end
