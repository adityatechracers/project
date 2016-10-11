class AddEmbedConfigToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :embed_help_text, :text
    add_column :organizations, :embed_thank_you, :text
  end
end
