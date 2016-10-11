class AddCanMakeTimecardsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_make_timecards, :boolean, :default => true
  end
end
