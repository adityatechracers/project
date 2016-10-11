class FroalaImageUpload < ActiveRecord::Base
  attr_accessible :image
  acts_as_tenant :organization
  validates :image, :organization_id, presence: true
  mount_uploader :image, FroalaImageUploader
end