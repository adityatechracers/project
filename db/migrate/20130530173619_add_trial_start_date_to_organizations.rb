class AddTrialStartDateToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :trial_start_date, :datetime
  end
end
