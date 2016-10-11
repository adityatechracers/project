# == Schema Information
#
# Table name: vendor_categories
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#

require 'spec_helper'

describe VendorCategory do
  pending "add some examples to (or delete) #{__FILE__}"
end
