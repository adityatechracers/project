class AddDateOfFirstJobScheduleEntry < ActiveRecord::Migration
  def up
    add_column(:jobs, :date_of_first_job_schedule_entry, :date)

    Job.all.each do |job|
      if(job.job_schedule_entries.count > 0)
        job.update_column(:date_of_first_job_schedule_entry,job.job_schedule_entries.order(:start_datetime).first.start_datetime.to_date)
      end
    end
    puts "Job.all update job.date_of_first_job_schedule_entry"
  end

  def down
    remove_column(:jobs, :date_of_first_job_schedule_entry)
  end
end
