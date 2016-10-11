class AddConfigsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :proposal_style, :string, null: false, default: 'CorkCRM'
    add_column :organizations, :uses_crew_commissions, :boolean, null: false, default: false
    add_column :organizations, :website_url, :string
  end
end
