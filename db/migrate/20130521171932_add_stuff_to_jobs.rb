class AddStuffToJobs < ActiveRecord::Migration
  def change
    change_table :jobs do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.float :amount, :precision => 10, :scale => 2
      t.float :budgeted_hours, :precision => 10, :scale => 2
      t.boolean :email_customer, :default => false
    end
  end
end
