class CommunicationRecord < Communication

  def when_indicator
    nc = self.datetime
    st = nc.strftime("%A, %B %e"+((nc.year!=Time.zone.now.year)?", %Y":"")+" at %l:%M%p")
    rt = self.datetime_distance
    "<span class='label next-contact-indicator' title='#{st}'>#{rt}</span>"
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
