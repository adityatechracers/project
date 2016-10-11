class AddFeedbackPortalTextToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :feedback_portal_text, :text
    add_column :organizations, :feedback_portal_show_signature, :boolean, default: false, null: false
  end
end
