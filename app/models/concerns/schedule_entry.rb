module ScheduleEntry
  extend ActiveSupport::Concern
  include Wisper::Publisher
  included do 
    after_create :publish_new_schedule_entry
    before_save :publish_start_date_time_changed, if: Proc.new {|model|  model.start_datetime_changed? && !model.new_record?} 
    after_destroy :publish_schedule_entry_removed
  end 
  def publish_new_schedule_entry
    broadcast(:new_schedule_entry, self)
  end 
  def publish_start_date_time_changed
    broadcast(:start_date_time_changed, self)
  end  
   def publish_schedule_entry_removed
    broadcast(:schedule_entry_removed, self)
  end  
  def enable_send_notifcation!
    unless new_record? 
      update_column :should_send_notification, true
    else 
      should_send_notification = true
    end   
  end   
end   