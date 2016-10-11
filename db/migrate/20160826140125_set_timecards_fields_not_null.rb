class SetTimecardsFieldsNotNull < ActiveRecord::Migration
  def up
    change_column :timecards, :start_datetime, :datetime, null: false
    change_column :timecards, :end_datetime, :datetime, null: false
    change_column :timecards, :job_id, :integer, null: false
    change_column :timecards, :user_id, :integer, null: false
  end

  def down
    change_column :timecards, :start_datetime, :datetime
    change_column :timecards, :end_datetime, :datetime
    change_column :timecards, :job_id, :integer
    change_column :timecards, :user_id, :integer
  end
end
