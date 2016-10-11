class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.integer :id
      t.integer :organization_id
      t.string :name
      t.text :subject
      t.text :body
      t.text :available_tokens
      t.boolean :enabled
      t.boolean :master, :default => false

      t.timestamps
    end
  end
end
