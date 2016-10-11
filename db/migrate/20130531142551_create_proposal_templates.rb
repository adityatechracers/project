class CreateProposalTemplates < ActiveRecord::Migration
  def change
    create_table :proposal_templates do |t|
      t.string :name
      t.integer :organization_id

      t.timestamps
    end
  end
end
