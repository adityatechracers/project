class CreateProposalSectionResponses < ActiveRecord::Migration
  def change
    create_table :proposal_section_responses do |t|
      t.integer :proposal_template_section_id
      t.integer :proposal_id
      t.text :description

      t.timestamps
    end
  end
end
