class AddStateChangeDateToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :state_change_date, :datetime
  end
end
