class AddModifiableToLeadSources < ActiveRecord::Migration
  def change
    add_column :lead_sources, :modifiable, :boolean, :default => true
  end
end
