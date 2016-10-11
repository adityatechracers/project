class ChangeStuffForProposals < ActiveRecord::Migration
  def up
    change_table :proposals do |t|
      t.remove :active
      t.string :proposal_state
    end
  end

  def down
    change_table :proposals do |t|
      t.boolean :active, :default => true
      t.remove :proposal_state
    end
  end
end
