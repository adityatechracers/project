class CreateProposalTemplateItems < ActiveRecord::Migration
  def change
    create_table :proposal_template_items do |t|
      t.string :name
      t.string :default_note_text
      t.string :help_text
      t.string :default_include_exclude_option
      t.integer :proposal_template_section_id

      t.timestamps
    end
  end
end
