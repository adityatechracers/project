class AddImageToFroalaImageUpload < ActiveRecord::Migration
  def change
    add_column :froala_image_uploads, :image, :string, null:false
  end
end
