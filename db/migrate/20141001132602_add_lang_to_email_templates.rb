class AddLangToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :lang, :string, null: false, default: 'en'
  end
end
