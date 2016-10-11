class AddExpectedStartAndEndDatesToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :expected_start_date, :date
    add_column :proposals, :expected_end_date, :date
  end
end
