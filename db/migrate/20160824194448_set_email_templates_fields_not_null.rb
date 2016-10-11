class SetEmailTemplatesFieldsNotNull < ActiveRecord::Migration
  def up
    change_column :email_templates, :subject, :text, null: false, default: ""
    change_column :email_templates, :body, :text, null: false, default: ""
  end

  def down
    change_column :email_templates, :subject, :text
    change_column :email_templates, :body, :text
  end
end
