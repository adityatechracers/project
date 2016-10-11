class AddPriorityToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :priority, :integer
  end
end
