class AddOwnerToOrganizationsWithoutIt < ActiveRecord::Migration
  def change

    Organization.all.each do |org|
      if org.owner.nil?
        new_owner = FactoryGirl.build(:user, first_name: "TEST_USER", last_name: "TEST_USER", email: Faker::Internet.email('test'), role: "Owner")
        org.owner = new_owner
      end
    end

  end
end
