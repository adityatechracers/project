class AddIsParseToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations ,:is_parse, :boolean, :default=> false
  end
end
