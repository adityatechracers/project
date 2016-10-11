class AddLoggableToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :loggable_id, :integer
    add_column :activities, :loggable_type, :string
  end
end
