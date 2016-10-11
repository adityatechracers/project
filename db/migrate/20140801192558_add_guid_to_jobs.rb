class AddGuidToJobs < ActiveRecord::Migration
  def up
    add_column :jobs, :guid, :string
    Job.find_each do |j|
      j.update_column(:guid, SecureRandom.uuid)
    end
  end

  def down
    remove_column :jobs, :guid
  end
end
