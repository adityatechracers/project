require "yaml"

class Activity < ActiveRecord::Base
  attr_accessible :event_type, :data, :loggable_id, :loggable_type

  belongs_to :loggable, :polymorphic => true
  
  has_paper_trail  only: [event_type: Proc.new { |model| model.event_type == Job::ACTIVITY_EVENT_TYPE} ]

  def culprit
    versions.last.try(:culprit)
  end   

  def yaml_data
    read_attribute(:data)
  end

  def data
    yd = self.yaml_data
    if yd.is_a? Hash then yd else YAML.load(yd) end
  end
end

# == Schema Information
#
# Table name: activities
#
#  id            :integer          not null, primary key
#  event_type    :string(255)
#  data          :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  loggable_id   :integer
#  loggable_type :string(255)
#
