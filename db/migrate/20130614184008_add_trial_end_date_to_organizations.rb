class AddTrialEndDateToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :trial_end_date, :datetime
  end
end
