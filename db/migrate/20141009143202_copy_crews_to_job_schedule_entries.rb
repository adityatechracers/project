class CopyCrewsToJobScheduleEntries < ActiveRecord::Migration
  def up
    # Set the schedule entry's crew if it's set on the job and we generated the
    # entry (in an earlier migration).
    JobScheduleEntry.where(system_generated: true).find_each do |entry|
      if entry.crew_id.blank? && entry.job.try(:crew_id).present?
        entry.update_attribute(:crew_id, entry.job.crew_id)
      end
    end
  end

  def down
  end
end
