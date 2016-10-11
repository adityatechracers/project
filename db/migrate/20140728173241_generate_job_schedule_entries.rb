class GenerateJobScheduleEntries < ActiveRecord::Migration
  class Job < ActiveRecord::Base; end
  class JobScheduleEntry < ActiveRecord::Base
    attr_protected :id
  end

  def up
    add_column :job_schedule_entries, :system_generated, :boolean, null: false, default: false

    JobScheduleEntry.reset_column_information

    Job.where('start_date IS NOT NULL AND end_date IS NOT NULL').find_each do |job|
      JobScheduleEntry.create!(
        job_id: job.id,
        start_datetime: job.start_date,
        end_datetime: job.end_date,
        system_generated: true
      )
    end
  end

  def down
    remove_column :job_schedule_entries, :system_generated
    JobScheduleEntry.where(system_generated: true).delete_all
  end
end
