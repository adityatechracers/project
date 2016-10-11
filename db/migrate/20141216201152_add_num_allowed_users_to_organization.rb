class AddNumAllowedUsersToOrganization < ActiveRecord::Migration
  def up
    add_column :organizations, :num_allowed_users, :integer, null: false, default: 1

    Organization.find_each do |org|
      puts "#{org.name} - #{org.plan.num_users rescue 1}"
      org.update_attribute(:num_allowed_users, (org.plan.num_users rescue 1))
    end
  end

  def down
    remove_column :organizations, :num_allowed_users
  end
end
