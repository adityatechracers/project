class ConvertProposalFieldsToText < ActiveRecord::Migration
  def up
    change_column :proposal_template_items, :default_note_text, :text
    change_column :proposal_item_responses, :notes, :text
  end

  def down
    change_column :proposal_template_items, :default_note_text, :string
    change_column :proposal_item_responses, :notes, :string
  end
end
