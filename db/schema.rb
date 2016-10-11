# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130624175923) do

  create_table "account_credits", :force => true do |t|
    t.decimal  "amount",          :precision => 9, :scale => 2
    t.integer  "organization_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  create_table "activities", :force => true do |t|
    t.string   "event_type"
    t.text     "data"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "loggable_id"
    t.string   "loggable_type"
  end

  create_table "appointments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "job_id"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.text     "notes"
    t.boolean  "email_before_appointment"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "organization_id"
    t.boolean  "sent_reminder",            :default => false
  end

  create_table "communications", :force => true do |t|
    t.integer  "job_id"
    t.integer  "user_id"
    t.text     "details"
    t.string   "outcome"
    t.string   "action"
    t.datetime "datetime"
    t.boolean  "datetime_exact"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "next_step"
    t.string   "type"
    t.integer  "organization_id"
    t.string   "note"
  end

  create_table "contacts", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "email"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "region"
    t.string   "zip"
    t.string   "country"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "organization_id"
    t.string   "company"
  end

  create_table "crews", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "organization_id"
    t.string   "color"
  end

  create_table "crews_users", :force => true do |t|
    t.integer "user_id"
    t.integer "crew_id"
  end

  add_index "crews_users", ["crew_id"], :name => "index_crews_users_on_crew_id"
  add_index "crews_users", ["user_id"], :name => "index_crews_users_on_user_id"

  create_table "email_templates", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.text     "subject"
    t.text     "body"
    t.text     "available_tokens"
    t.boolean  "enabled"
    t.boolean  "master",           :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.text     "description"
  end

  create_table "expenses", :force => true do |t|
    t.integer  "job_id"
    t.integer  "organization_id"
    t.decimal  "amount",          :precision => 9, :scale => 2
    t.text     "description"
    t.date     "date_of_expense"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  create_table "job_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "job_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "job_users", ["job_id"], :name => "index_job_users_on_job_id"
  add_index "job_users", ["user_id"], :name => "index_job_users_on_user_id"

  create_table "jobs", :force => true do |t|
    t.string   "title"
    t.integer  "lead_source_id"
    t.integer  "contact_id"
    t.text     "details"
    t.integer  "probability"
    t.string   "state"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "email_customer",                                 :default => false
    t.integer  "crew_id"
    t.boolean  "active",                                         :default => true
    t.integer  "organization_id"
    t.decimal  "estimated_amount", :precision => 9, :scale => 2, :default => 0.0
  end

  create_table "lead_sources", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "modifiable",      :default => true
  end

  create_table "lead_uploads", :force => true do |t|
    t.string   "csv_file_name"
    t.string   "csv_content_type"
    t.integer  "csv_file_size"
    t.datetime "csv_updated_at"
    t.string   "name"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "guid"
    t.boolean  "premium_override"
    t.string   "stripe_plan_id"
    t.string   "stripe_customer_token"
    t.boolean  "last_payment_successful"
    t.datetime "last_payment_date"
    t.string   "stripe_plan_name"
    t.string   "name_on_credit_card"
    t.string   "last_four_digits"
    t.string   "address"
    t.string   "address_2"
    t.string   "city"
    t.string   "region"
    t.string   "zip"
    t.string   "email"
    t.string   "phone"
    t.string   "fax"
    t.string   "license_number"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "timecard_lock_period"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "active",                  :default => true
    t.datetime "trial_start_date"
    t.text     "embed_help_text"
    t.text     "embed_thank_you"
    t.string   "time_zone"
    t.datetime "trial_end_date"
    t.string   "country"
  end

  create_table "payments", :force => true do |t|
    t.integer  "job_id"
    t.integer  "organization_id"
    t.date     "date_paid"
    t.decimal  "amount",          :precision => 9, :scale => 2
    t.string   "payment_type"
    t.string   "notes"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  create_table "proposal_item_responses", :force => true do |t|
    t.integer  "proposal_template_item_id"
    t.integer  "proposal_section_response_id"
    t.string   "include_exclude_option"
    t.string   "notes"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "proposal_section_responses", :force => true do |t|
    t.integer  "proposal_template_section_id"
    t.integer  "proposal_id"
    t.text     "description"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "proposal_template_items", :force => true do |t|
    t.string   "name"
    t.string   "default_note_text"
    t.string   "help_text"
    t.string   "default_include_exclude_option"
    t.integer  "proposal_template_section_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "proposal_template_sections", :force => true do |t|
    t.string   "name"
    t.text     "default_description"
    t.integer  "proposal_template_id"
    t.string   "background_color"
    t.string   "foreground_color"
    t.boolean  "show_include_exclude_options", :default => true
    t.integer  "position"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  create_table "proposal_templates", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "active",          :default => true
    t.text     "agreement"
  end

  create_table "proposals", :id => false, :force => true do |t|
    t.string   "title"
    t.integer  "job_id"
    t.integer  "proposal_template_id"
    t.integer  "proposal_number"
    t.string   "address"
    t.string   "city"
    t.string   "region"
    t.string   "zip"
    t.string   "license_number"
    t.string   "proposal_class"
    t.string   "speciality"
    t.date     "proposal_date"
    t.integer  "sales_person_id"
    t.integer  "contractor_id"
    t.integer  "organization_id"
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
    t.string   "address2"
    t.string   "country"
    t.text     "notes"
    t.integer  "signed_by"
    t.string   "customer_sig_printed_name"
    t.text     "customer_sig"
    t.integer  "customer_sig_user_id"
    t.string   "contractor_sig_printed_name"
    t.text     "contractor_sig"
    t.integer  "contractor_sig_user_id"
    t.string   "proposal_state"
    t.decimal  "amount",                      :precision => 9, :scale => 2, :default => 0.0
    t.text     "agreement"
    t.datetime "customer_sig_datetime"
    t.datetime "contractor_sig_datetime"
    t.string   "guid",                                                                       :null => false
    t.integer  "budgeted_hours",                                            :default => 0
  end

  create_table "quotes", :force => true do |t|
    t.string   "quote"
    t.string   "author"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "timecards", :force => true do |t|
    t.integer  "job_id"
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.text     "notes"
    t.string   "state"
    t.decimal  "amount",          :precision => 9, :scale => 2
    t.float    "duration"
    t.decimal  "pay_rate",        :precision => 9, :scale => 2
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                                             :default => "",      :null => false
    t.string   "encrypted_password",                                                :default => "",      :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                                     :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                                             :null => false
    t.datetime "updated_at",                                                                             :null => false
    t.integer  "organization_id"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "phone"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "region"
    t.string   "zip"
    t.boolean  "active",                                                            :default => true
    t.boolean  "can_view_leads",                                                    :default => true
    t.boolean  "can_manage_leads",                                                  :default => true
    t.boolean  "can_view_appointments",                                             :default => true
    t.boolean  "can_manage_appointments",                                           :default => true
    t.boolean  "can_view_all_jobs",                                                 :default => true
    t.boolean  "can_view_own_jobs",                                                 :default => true
    t.boolean  "can_manage_jobs",                                                   :default => true
    t.boolean  "can_view_all_proposals",                                            :default => true
    t.boolean  "can_view_assigned_proposals",                                       :default => true
    t.boolean  "can_manage_proposals",                                              :default => true
    t.boolean  "can_be_assigned_appointments",                                      :default => true
    t.boolean  "can_be_assigned_jobs",                                              :default => true
    t.string   "role",                                                              :default => "Owner"
    t.string   "country"
    t.decimal  "pay_rate",                            :precision => 9, :scale => 2, :default => 0.0
    t.boolean  "admin_can_view_failing_credit_cards",                               :default => false
    t.boolean  "admin_can_view_billing_history",                                    :default => false
    t.boolean  "admin_can_manage_accounts",                                         :default => false
    t.boolean  "admin_can_manage_trials",                                           :default => false
    t.boolean  "admin_can_manage_cms",                                              :default => false
    t.boolean  "admin_can_become_user",                                             :default => false
    t.boolean  "admin_receives_notifications",                                      :default => false
    t.boolean  "super",                                                             :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
