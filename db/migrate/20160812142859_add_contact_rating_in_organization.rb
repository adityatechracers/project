class AddContactRatingInOrganization < ActiveRecord::Migration
  def up
    add_column :organizations, :show_customer_rating, :boolean
  end

  def down
  end
end
