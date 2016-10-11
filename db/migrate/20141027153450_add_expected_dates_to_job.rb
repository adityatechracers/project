class AddExpectedDatesToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :expected_start_date, :date
    add_column :jobs, :expected_end_date, :date
  end
end
