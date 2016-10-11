# == Schema Information
#
# Table name: proposal_files
#
#  id                 :integer          not null, primary key
#  file               :string(255)
#  original_file_name :string(255)
#  proposal_id        :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'spec_helper'

describe ProposalFile do
  pending "add some examples to (or delete) #{__FILE__}"
end
