class AddCrewIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :crew_id, :integer
  end
end
