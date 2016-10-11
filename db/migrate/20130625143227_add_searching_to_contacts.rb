class AddSearchingToContacts < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    execute "create index contacts_searchable_first_name on contacts using gin(to_tsvector('english', first_name));"
    execute "create index contacts_searchable_last_name on contacts using gin(to_tsvector('english', last_name));"
    execute "create index contacts_searchable_address on contacts using gin(to_tsvector('english', address));"
    execute "create index contacts_searchable_address2 on contacts using gin(to_tsvector('english', address2));"
    execute "create index contacts_searchable_city on contacts using gin(to_tsvector('english', city));"
    execute "create index contacts_searchable_region on contacts using gin(to_tsvector('english', region));"
    execute "create index contacts_searchable_country on contacts using gin(to_tsvector('english', country));"
    execute "create index contacts_searchable_zip on contacts using gin(to_tsvector('english', zip));"
  end

  def down
    execute "DROP EXTENSION IF NOT EXISTS pg_trgm;"
    execute "drop index contacts_searchable_first_name;"
    execute "drop index contacts_searchable_last_name;"
    execute "drop index contacts_searchable_address;"
    execute "drop index contacts_searchable_address2;"
    execute "drop index contacts_searchable_city;"
    execute "drop index contacts_searchable_region;"
    execute "drop index contacts_searchable_country;"
    execute "drop index contacts_searchable_zip;"
  end
end
