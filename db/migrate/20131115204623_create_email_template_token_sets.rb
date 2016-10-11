class CreateEmailTemplateTokenSets < ActiveRecord::Migration
  def up
    # Make updating email tokens easier. Clones can just reference the
    # token set.
    create_table :email_template_token_sets do |t|
      t.string :template_name
      t.text :available_tokens

      t.timestamps
    end
    remove_column :email_templates, :available_tokens
  end

  def down
    drop_table :email_template_tokens
    add_column :email_templates, :available_tokens, :text
  end
end
