require 'spec_helper'

describe 'owner edits organization details', :js => true do

  it 'does not allow employees to edit organization info' do
    employee = log_in(create :user, :employee)
    page.should_not have_content 'Owner'
    visit '/manage/organization/edit'
    page.should have_content 'You do not have permission to'
  end

  it 'allows owner to edit organization details' do
    owner = log_in(create :user, :owner)
    visit '/manage/organization/edit'
    page.should have_content 'Edit Organization'

    within "#edit_organization_#{owner.organization.id}" do
      fill_in 'organization_address', :with => '1234 Main St.'
      fill_in 'organization_address_2', :with => 'Suite 42'
      fill_in 'organization_fax', :with => '800.321.4214'
      click_on 'Save Organization'
    end

    page.should have_content 'Organization was successfully updated'

    found_org = Organization.find(owner.organization.id)
    found_org.address.should == '1234 Main St.'
    found_org.address_2.should == 'Suite 42'
    found_org.fax.should == '(800) 321-4214'
  end
end
