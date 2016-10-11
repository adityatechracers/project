class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.integer :user_id
      t.integer :job_id
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.text :notes
      t.boolean :email_before_appointment

      t.timestamps
    end
  end
end
