class PersonalProposalTemplate < ProposalTemplate

  def self.model_name
    ProposalTemplate.model_name
  end

  def is_upload_your_own?
    true
  end
end
