class DropCkeditorAssets < ActiveRecord::Migration
  def up
    drop_table(:ckeditor_assets) if table_exists? :ckeditor_assets
  end

  def down
  end
end
