class MoveBudgetedHoursToProposals < ActiveRecord::Migration
  def up
    remove_column :jobs, :budgeted_hours
    add_column :proposals, :budgeted_hours, :integer, :default => 0
  end

  def down
    add_column :jobs, :budgeted_hours, :integer, :default => 0
    remove_column :proposals, :budgeted_hours
  end
end
