class AddDefaultSignatureToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :default_signature, :text
    add_column :organizations, :auto_sign_proposals, :boolean, default: false, null: false
  end
end
