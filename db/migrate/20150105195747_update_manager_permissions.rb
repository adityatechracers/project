class UpdateManagerPermissions < ActiveRecord::Migration
  def up
    # Ensure that all privileged users have all employee permissions.
    # It was briefly possible to create managers with limited permissions.
    User
      .where(role: ['Manager', 'Owner', 'Admin'])
      .update_all(Hash[User::PERMISSION_FLAGS.map { |f| [f, true] }])
  end

  def down
  end
end
