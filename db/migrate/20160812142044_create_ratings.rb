class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.text :rating
    end
  end
end
