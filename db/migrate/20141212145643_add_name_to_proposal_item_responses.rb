class AddNameToProposalItemResponses < ActiveRecord::Migration
  def up
    add_column :proposal_item_responses, :name, :string
    ProposalItemResponse.find_each do |item_response|
      item_response.update_attribute(:name, item_response.template_item.name)
    end
  end

  def down
    remove_column :proposal_item_responses, :name
  end
end
