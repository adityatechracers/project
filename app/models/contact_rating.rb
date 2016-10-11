class ContactRating < ActiveRecord::Base
  attr_accessible :contact_id, :rating_id, :stage
  belongs_to :contact
  belongs_to :rating
end
