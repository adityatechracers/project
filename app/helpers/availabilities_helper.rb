module AvailabilitiesHelper
  def one_week_forward(date)
    date + 7
  end

  def one_week_back(date)
    date - 7
  end

  def get_employee_photo(employee)
    employee.image_url.present? ? employee.image_url : 'profile.jpg'
  end

  def event_boxes(employee, date)
    html = ''
    appointments = employee.appointments_with_google_events(date)
    if appointments.any?
      appointments.each do |a|
        if a.is_a? Appointment
          time = a.start_datetime.strftime("%I:%M %P") if a.start_datetime.present?
          if a.job.present? and a.job.contact.present?
            name = a.job.contact.name
            address = a.job.contact.minimized_condensed_address
          else
            name = 'Availability'
            address = ''
          end
          html += "<div id='appointment-box' class='btn btn-success btn-block btn-outline appointment-box' data-link='/availabilities/#{date}/appointment_modal?appointment=#{a.id}&employee=#{employee.id}'>
          <div>#{time}</div>
          <div>#{name}</div>
          <div>#{address}</div>
          </div>"
        elsif a.is_a? GoogleEvent
          start_time = a.start_datetime.strftime("%I:%M %P") if a.start_datetime.present?
          end_time = a.end_datetime.strftime("%I:%M %P") if a.end_datetime.present?
          name = a.title
          html += "<button class='btn btn-success btn-block btn-outline appointment-box' type='button'>
          <div>#{start_time} - #{end_time}</div>
          <div class='google_event_name'>#{name}</div>
          </button>"
        end
      end
    else
      html = "<button class='btn btn-success btn-block btn-outline appointment-box' type='button'>
      <div>Available all day</div>
      </button>"
    end
    html
  end

end
