class AddNextStepToCommunications < ActiveRecord::Migration
  def change
    change_table :communications do |t|
      t.string :next_step
    end
  end
end
