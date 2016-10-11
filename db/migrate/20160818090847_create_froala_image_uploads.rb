class CreateFroalaImageUploads < ActiveRecord::Migration
  def change
    create_table :froala_image_uploads do |t|
      t.belongs_to :organization
      t.timestamps
    end
  end
end
