class AddDeadToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :dead, :boolean, null: false, default: false
  end
end
