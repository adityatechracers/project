class SetEmailToOrganizationsWithoutIt < ActiveRecord::Migration
  def up
    Organization.find_each(conditions: "email IS NULL OR email = ''") do |org|
      org.update_attribute(:email, (org.owner.email rescue "example@email.com"))
    end
  end

  def down
  end
end
