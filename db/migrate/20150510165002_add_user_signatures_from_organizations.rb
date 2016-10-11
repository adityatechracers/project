class AddUserSignaturesFromOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :user_signatures, :text
  end
end
