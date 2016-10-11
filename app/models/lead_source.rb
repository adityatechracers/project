class LeadSource < ActiveRecord::Base
  attr_accessible :name, :organization_id, :modifiable

  has_many :jobs

  acts_as_tenant :organization

  validates :name, presence: true

  # For non-modifiable, baked-in lead sources, look up a translation.
  # If modifiable, the user has supplied the name and it should be returned as is.
  def locale_name
		if deleted_at.nil?
    	modifiable ? name : I18n.t("lead_sources.#{name.parameterize.underscore}")
  	end
  end
end

# == Schema Information
#
# Table name: lead_sources
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  modifiable      :boolean          default(TRUE)
#  deleted_at      :datetime
#
