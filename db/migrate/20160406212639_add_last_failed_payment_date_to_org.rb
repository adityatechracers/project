class AddLastFailedPaymentDateToOrg < ActiveRecord::Migration
  def up
    add_column :organizations, :last_failed_payment_date, :date, default: nil
  end

  def down
    remove_column :organizations, :last_failed_payment_date
  end
end
