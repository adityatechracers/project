module LeadsHelper
  include ContactsHelper

  def next_communication_indicator_label_class(communication)
    label_type = 'indicator-cell '
    return label_type unless communication.present?
    label_type += if communication.datetime < Time.zone.now.end_of_day.to_datetime
                    'indicator-cell-important'
                  elsif communication.datetime < 7.days.since(Time.zone.now).to_datetime
                    'indicator-cell-warning'
                  else
                    'indicator-cell-success'
                  end
  end
end
