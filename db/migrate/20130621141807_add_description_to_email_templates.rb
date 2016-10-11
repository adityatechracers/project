class AddDescriptionToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :description, :text
  end
end
