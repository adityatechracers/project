class SetProposalsFieldsNotNull < ActiveRecord::Migration
  def up
    change_column :proposals, :job_id, :integer, null: false
    change_column :proposals, :amount, :decimal, precision: 9, scale: 2, default: 0, null: false
    change_column :proposals, :budgeted_hours, :integer, default: 0, null: false
  end

  def down
    change_column :proposals, :job_id, :integer
    change_column :proposals, :amount, :decimal, precision: 9, scale: 2, default: 0
    change_column :proposals, :budgeted_hours, :integer, default: 0
  end
end
