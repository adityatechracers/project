class Quote < ActiveRecord::Base
  attr_accessible :author, :quote

  def self.random
    Quote.first(:offset => rand(Quote.count))
  end
end

# == Schema Information
#
# Table name: quotes
#
#  id         :integer          not null, primary key
#  quote      :string(255)
#  author     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
