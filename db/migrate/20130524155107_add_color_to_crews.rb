class AddColorToCrews < ActiveRecord::Migration
  def change
    add_column :crews, :color, :string
  end
end
