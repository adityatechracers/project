class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :guid
      t.boolean :premium_override
      t.string :stripe_plan_id
      t.string :stripe_customer_token
      t.boolean :last_payment_successful
      t.datetime :last_payment_date
      t.string :stripe_plan_name
      t.string :name_on_credit_card
      t.string :last_four_digits
      t.string :address
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :email
      t.string :phone
      t.string :fax
      t.string :license_number
      t.attachment :logo
      t.string :timecard_lock_period
      t.datetime :timecard_lock_date

      t.timestamps
    end
  end
end
