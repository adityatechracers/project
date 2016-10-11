class AddAddedByToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :added_by, :integer
  end
end
