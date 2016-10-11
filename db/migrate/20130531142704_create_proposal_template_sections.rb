class CreateProposalTemplateSections < ActiveRecord::Migration
  def change
    create_table :proposal_template_sections do |t|
      t.string :name
      t.text :default_description
      t.integer :proposal_template_id
      t.string :background_color
      t.string :foreground_color
      t.boolean :show_include_exclude_options, :default => true
      t.integer :position

      t.timestamps
    end
  end
end
