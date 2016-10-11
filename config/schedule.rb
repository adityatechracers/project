# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
  
every :hour do
  runner 'Appointment.send_reminders'
  runner 'Appointment.send_confirmations'
end 

every :hour do   
  rake "jobs:notify:scheduled_job_entry"
end

every :day do   
  rake "quick_books:renew:expiring_tokens"
end

every :day do
  runner 'Organization.send_trial_2_day_follow_ups'
  runner 'Organization.send_trial_7_day_follow_ups'
  runner 'Organization.send_trial_10_day_follow_ups'
  runner 'Organization.send_trial_expiration_notices'
  runner 'Organization.send_expired_7_day_follow_ups'
  runner 'Organization.send_expired_1_month_follow_ups'
  runner 'Organization.send_active_1_month_follow_ups'
  runner 'Organization.send_failed_payment_reminder'

  runner 'Proposal.send_issued_2_day_reminders'
  runner 'Proposal.send_issued_1_week_reminders'
  runner 'Proposal.send_issued_1_month_reminders'
  runner 'Proposal.send_issued_2_month_reminders'
  runner 'Proposal.send_issued_3_month_reminders'

  runner 'Job.send_appointment_2_day_follow_ups'
  runner 'Job.send_appointment_7_day_follow_ups'
  runner 'Job.send_job_complete_1_month_follow_ups'

  runner 'JobScheduleEntry.send_reminders'
end
