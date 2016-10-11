class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.string :meta_title
      t.text :meta_description
      t.text :summary
      t.text :description
      t.string :slug
      t.datetime :published_date
      t.integer :category_id

      t.timestamps
    end
  end
end
