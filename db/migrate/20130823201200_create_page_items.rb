class CreatePageItems < ActiveRecord::Migration
  def change
    create_table :page_items do |t|
      t.string :name
      t.integer :page_id
      t.text :content

      t.timestamps
    end
  end
end
