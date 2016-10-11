class CreateLeadUploads < ActiveRecord::Migration
  def change
    create_table :lead_uploads do |t|
      t.attachment :csv
      t.string :name
      t.timestamps
    end
  end
end
