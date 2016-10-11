class GoogleCalendarsController < ApplicationController

  def choose
    user_calendars = GoogleCalendar.where(user_id: params['user_id']) if params['user_id']
    user_calendars_ids = user_calendars.shareable.pluck(:id)
    # shared_calendars_ids = []
    # shared_calendars_ids = params['calendar_ids'].collect {|id| id.to_i} if params['calendar_ids']
    shared_calendar_id = params['shared_calendar'].to_i
    shared_calendar = GoogleCalendar.find shared_calendar_id

    user_calendars_ids.delete shared_calendar_id

    shared_calendar.update_attribute(:shared, true) if shared_calendar.present?

    unless user_calendars_ids.empty?
      GoogleCalendar.update_all({shared: false}, {id: user_calendars_ids})
    end

    redirect_to appointments_path
  end

end
