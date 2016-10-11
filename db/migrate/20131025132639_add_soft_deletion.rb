class AddSoftDeletion < ActiveRecord::Migration
  def up
    add_column :appointments, :deleted_at, :datetime
    add_column :contacts, :deleted_at, :datetime
    add_column :communications, :deleted_at, :datetime
    add_column :crews, :deleted_at, :datetime
    add_column :expenses, :deleted_at, :datetime
    add_column :job_users, :deleted_at, :datetime
    add_column :jobs, :deleted_at, :datetime
    add_column :lead_sources, :deleted_at, :datetime
    add_column :payments, :deleted_at, :datetime
    add_column :posts, :deleted_at, :datetime
    add_column :proposals, :deleted_at, :datetime
    add_column :proposal_templates, :deleted_at, :datetime
    add_column :timecards, :deleted_at, :datetime

    remove_column :jobs, :active
  end

  def down
    remove_column :appointments, :deleted_at
    remove_column :contacts, :deleted_at
    remove_column :communications, :deleted_at
    remove_column :crews, :deleted_at
    remove_column :expenses, :deleted_at
    remove_column :job_users, :deleted_at
    remove_column :jobs, :deleted_at
    remove_column :lead_sources, :deleted_at
    remove_column :payments, :deleted_at
    remove_column :posts, :deleted_at
    remove_column :proposals, :deleted_at
    remove_column :proposal_templates, :deleted_at
    remove_column :timecards, :deleted_at

    add_column :jobs, :active, :boolean, :default => true
  end
end
