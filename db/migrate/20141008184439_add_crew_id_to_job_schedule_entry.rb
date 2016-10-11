class AddCrewIdToJobScheduleEntry < ActiveRecord::Migration
  def change
    add_column :job_schedule_entries, :crew_id, :integer
  end
end
