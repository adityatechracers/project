class PageItem < ActiveRecord::Base
  attr_accessible :content, :name, :page_id
end

# == Schema Information
#
# Table name: page_items
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  page_id    :integer
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
