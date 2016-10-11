class Jobs::QB::WebHooks::WebHooksHandler 
  include SuckerPunch::Job
  def perform event_notifications
    process event_notifications
  end   
  private
  def process event_notifications
    init_changes
    event_notifications.each do |event_notification| 
      collect_changes to_object(event_notification)
    end 
    process_changes
  end 
  def process_changes
    @changes.each do |entity, attributes|
      entity_processor(entity).perform attributes
    end    
  end   
  def map_entity entity
    entity.sub('Purchase', 'Expense')
  end   
  def entity_processor entity 
    "Jobs::QB::WebHooks::Update#{map_entity(entity.capitalize.pluralize)}".constantize
  end   
  def init_changes
    @changes = {}
  end   
  def to_object hash
    RecursiveOpenStruct.new hash
  end    
  def collect_changes notification
    company = notification.realmId
    notification.dataChangeEvent.entities.each do |change_event|
      event = to_object change_event
      event_name = event.name
      @changes[event_name][:companies] << company if @changes[event_name].present?
      @changes[event_name] ||={companies:[company], since:(Time.now)}.with_indifferent_access
      @changes[event_name][:since] = event.lastUpdated if event.lastUpdated < @changes[event_name][:since].to_time 
    end   
  end       
end 