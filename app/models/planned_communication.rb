class PlannedCommunication < Communication

  def when_indicator
    nc = self.datetime
    labeltype = (nc < 1.days.since(Time.zone.now).to_datetime)?"important":((nc < 7.days.since(Time.zone.now).to_datetime)?"warning":"success")
    labelday = if nc.to_date.today? then "Today" else if nc.to_date == Date.tomorrow then "Tomorrow" else "%A, %B %e"+(nc.year!=Time.zone.now.year ? ", %Y":"") end end
    rt = self.datetime_distance
    st = nc.strftime("#{labelday} at %l:%M%p")
    "<span class='label label-#{labeltype} contact-when-indicator' title='#{rt}'>#{st}</span>"
  end

end

# == Schema Information
#
# Table name: communications
#
#  id              :integer          not null, primary key
#  job_id          :integer
#  user_id         :integer
#  details         :text
#  outcome         :string(255)
#  action          :string(255)
#  datetime        :datetime
#  datetime_exact  :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  next_step       :string(255)
#  type            :string(255)
#  organization_id :integer
#  note            :string(255)
#  deleted_at      :datetime
#
