class AddActiveToJobs < ActiveRecord::Migration
  def change
    change_table :jobs do |t|
      t.boolean :active, :default => true
    end
  end
end
