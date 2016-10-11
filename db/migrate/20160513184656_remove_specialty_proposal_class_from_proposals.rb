class RemoveSpecialtyProposalClassFromProposals < ActiveRecord::Migration
  def change
    [:speciality, :proposal_class].each do |column| 
      remove_column(:proposals, column)
    end   
  end   
end
