class AddZestimateToOrganization < ActiveRecord::Migration
  def change
  	add_column :organizations, :show_zestimate, :boolean
  end
end
