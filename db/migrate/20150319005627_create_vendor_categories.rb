class CreateVendorCategories < ActiveRecord::Migration
  def change
    create_table :vendor_categories do |t|

      #add_column :expenses, :expense_category_id, :integer
      t.belongs_to :organization
      t.string :name
      t.timestamps
      t.datetime :deleted_at
    end
  end
end
