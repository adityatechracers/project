class AddWageRateToCrewsJobs < ActiveRecord::Migration
  def change
    add_column :crews, :wage_rate, :decimal, :precision => 9, :scale => 2
    add_column :jobs, :crew_wage_rate, :decimal, :precision => 9, :scale => 2
    add_column :jobs, :crew_expense_id, :integer
  end
end
