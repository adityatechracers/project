class Post < ActiveRecord::Base
  default_scope order("posts.published_date DESC")
  attr_accessible :description, :meta_description, :meta_title, :published_date, :slug, :summary, :title
  paginates_per 5
  validates_presence_of :title, :slug, :published_date, :summary, :description
  slugged({:slug => :title, :auto_override => true})

  scope :active, not_deleted.where("posts.published_date < ?", DateTime.now)

  def self.most_recent
    active.order('published_date DESC').first
  end
end

# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  title            :string(255)
#  meta_title       :string(255)
#  meta_description :text
#  summary          :text
#  description      :text
#  slug             :string(255)
#  published_date   :datetime
#  category_id      :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#
