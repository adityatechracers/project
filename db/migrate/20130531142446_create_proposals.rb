class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      t.string :title
      t.boolean :active, :default => true
      t.integer :job_id
      t.integer :proposal_template_id
      t.integer :proposal_number
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :license_number
      t.string :proposal_class
      t.string :speciality
      t.date :proposal_date
      t.integer :sales_person_id
      t.integer :contractor_id
      t.integer :organization_id

      t.timestamps
    end
  end
end
