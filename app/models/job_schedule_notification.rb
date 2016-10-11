class JobScheduleNotification < ActiveRecord::Base
  belongs_to :job_schedule_entry
  validates :job_schedule_entry, presence:true
  attr_accessible :job_schedule_entry_id
  def entry 
    job_schedule_entry
  end  
  def self.add_entry! entry 
    find_or_create_by_job_schedule_entry_id entry.id
  end   
  def self.remove_entry entry 
    delete_all job_schedule_entry_id:entry.id
  end   
end
