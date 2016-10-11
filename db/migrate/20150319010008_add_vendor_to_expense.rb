class AddVendorToExpense < ActiveRecord::Migration
  def change
     add_column :expenses, :vendor_category_id, :integer
  end
end
