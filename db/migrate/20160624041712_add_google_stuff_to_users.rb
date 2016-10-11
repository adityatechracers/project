class AddGoogleStuffToUsers < ActiveRecord::Migration
  def change
    add_column :users, :google_auth_token, :string
    add_column :users, :google_auth_refresh_token, :string
    add_column :users, :google_auth_expires_at, :datetime
    add_column :users, :connected_to_google, :boolean
    add_column :users, :google_email, :string
  end
end
