class CreateProposalFiles < ActiveRecord::Migration
  def change
    create_table :proposal_files do |t|
      t.string :file
      t.string :original_file_name
      t.integer :proposal_id
      t.timestamps
    end
  end
end
