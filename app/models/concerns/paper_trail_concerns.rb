module PaperTrailConcerns
  extend ActiveSupport::Concern
  included do 
    validates :whodunnit, presence:true
    belongs_to :culprit, class_name: "User", foreign_key: :whodunnit
  end   
end   