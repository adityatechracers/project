class Category < ActiveRecord::Base
  attr_accessible :name, :slug
  validates_presence_of :name, :slug
  has_many :posts
  slugged({:slug => :name, :auto_override => true})
end

# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  slug       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
