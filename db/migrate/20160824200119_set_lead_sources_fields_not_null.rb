class SetLeadSourcesFieldsNotNull < ActiveRecord::Migration
  def up
    change_column :lead_sources, :name, :string, null: false, default: ""
  end

  def down
    change_column :lead_sources, :name, :string
  end
end
