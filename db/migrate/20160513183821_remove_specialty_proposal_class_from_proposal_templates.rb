class RemoveSpecialtyProposalClassFromProposalTemplates < ActiveRecord::Migration
  def change
    [:speciality, :proposal_class].each do |column| 
      remove_column(:proposal_templates, column)
    end   
  end   
end
