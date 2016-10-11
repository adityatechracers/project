class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :event_type
      t.text :data
      t.timestamps
    end
  end
end
