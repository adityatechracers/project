class CreateProposalItemResponses < ActiveRecord::Migration
  def change
    create_table :proposal_item_responses do |t|
      t.integer :proposal_template_item_id
      t.integer :proposal_section_response_id
      t.string :include_exclude_option
      t.string :notes

      t.timestamps
    end
  end
end
