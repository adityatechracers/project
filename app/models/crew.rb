class Crew < ActiveRecord::Base
  attr_accessible :id, :name, :organization_id, :user_ids, :wage_rate, :has_wage_rate, :color
  attr_accessor :has_wage_rate
  has_and_belongs_to_many :users
  before_save :set_color, :if => Proc.new {|object| object.color.nil?}

  has_many :jobs
  has_many :payments, through: :jobs
  has_many :expenses, through: :jobs

  validates :name, presence: true

  acts_as_tenant :organization

  CREW_COLORS = [
    '#809FFF', '#9F80FF', '#DF80FF', '#FF80DF',
    '#FF809F', '#FF9F80', '#FFDF80', '#DFFF80',
    '#9FFF80', '#80FF9F', '#80FFDF', '#80DFFF',
    '#4271FF', '#0544FF', '#FFD042', '#FFC105'
  ]

  def set_color
    available = CREW_COLORS - Crew.all.map(&:color)
    return self.color = CREW_COLORS[0] if available.empty?
    self.color = available.sample
  end

  def has_wage_rate
    wage_rate.present?
  end
end

# == Schema Information
#
# Table name: crews
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#  color           :string(255)
#  deleted_at      :datetime
#  wage_rate       :decimal(9, 2)
#
