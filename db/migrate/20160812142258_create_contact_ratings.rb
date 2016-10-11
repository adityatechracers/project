class CreateContactRatings < ActiveRecord::Migration
  def change
    create_table :contact_ratings do |t|
      t.integer :contact_id
      t.integer :rating_id
      t.text :stage
    end
  end
end
