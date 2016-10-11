class Rating < ActiveRecord::Base
  attr_accessible :rating,:id
  has_many :contact_ratings
  has_many :contacts, :through => :contact_ratings

  def locale_name
    rating
  end
end
