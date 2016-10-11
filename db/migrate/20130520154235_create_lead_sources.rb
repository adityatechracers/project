class CreateLeadSources < ActiveRecord::Migration
  def change
    create_table :lead_sources do |t|
      t.string :name
      t.integer :organization_id
      t.timestamps
    end
  end
end
