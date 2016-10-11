class AddUserIdToExpenses < ActiveRecord::Migration
  def up
    add_column :expenses, :user_id, :integer
  end

  def down
    remove_column :expenses, :user_id
  end
end
