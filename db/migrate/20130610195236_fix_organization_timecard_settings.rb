class FixOrganizationTimecardSettings < ActiveRecord::Migration
  def up
    change_table :organizations do |t|
      t.remove :timecard_lock_date
    end
  end

  def down
    change_table :organizations do |t|
      t.datetime :timecard_lock_date
    end
  end
end
