module JobNotifications 
  extend ActiveSupport::Concern
  module ClassMethods 
    def send_notifications
      logger.info ">>>> JobNotifications: Begin Processing"
      processed = []
      JobScheduleNotification.includes(:job_schedule_entry).each do |notification|  
        schedule_entry = notification.entry  
        ActsAsTenant.with_tenant(schedule_entry.job.organization) do
          if JobsMailer.job_scheduled_notification_enabled? && schedule_entry.should_send_notification?
            JobsMailer.job_scheduled_notification(schedule_entry.job, schedule_entry).deliver
            schedule_entry.update_column(:should_send_notification, false)
            schedule_entry.update_column(:sent_notification, true)
          end 
          processed.push notification.id 
        end
      end
      JobScheduleNotification.where(id:processed).delete_all unless processed.empty?
      logger.info "<<<<< JobNotifications: End Processing (#{processed.count})"
    end
  end 
end   