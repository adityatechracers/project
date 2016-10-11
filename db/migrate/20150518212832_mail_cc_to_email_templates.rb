class MailCcToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :mail_to_cc, :string
  end
end
