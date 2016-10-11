class CreateInquiries < ActiveRecord::Migration
  def change
    create_table :inquiries do |t|
      t.integer :id
      t.string :name
      t.string :email
      t.text :message

      t.timestamps
    end
  end
end
