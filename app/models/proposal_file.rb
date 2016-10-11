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
#  type               :string
#

class ProposalFile < ActiveRecord::Base
  attr_accessible :file, :original_file_name, :proposal_id, :type

  mount_uploader :file, ProposalFileUploader

  belongs_to :proposal

  def is_primary_proposal_file?
    false
  end

  def is_personal_proposal_file?
    false
  end

  def is_secondary_proposal_file?
    false
  end
end
