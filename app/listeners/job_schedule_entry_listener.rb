class JobScheduleEntryListener
  def start_date_time_changed entry
    Rails.logger.info "listener: start_date_time_changed"
    add_entry entry  
  end   
  def new_schedule_entry entry
    Rails.logger.info "listener: new_schedule_entry" 
    add_entry entry 
  end   
  def schedule_entry_removed entry
    Rails.logger.info "listener: schedule_entry_removed" 
    remove_entry entry 
  end   
  private 
  def add_entry entry 
    entry.enable_send_notifcation!
    JobScheduleNotification.add_entry! entry
  end 
  def remove_entry entry 
    JobScheduleNotification.remove_entry entry
  end 
end   