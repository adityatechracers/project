require 'ffaker'
require 'pp'

# Seed with test data
namespace :test_data do
  task :all => [:reset, :owners, :crews, :employees, :leads]

  task :reset => :environment do
    raise "Don't run this in production!" if Rails.env.production?

    Contact.delete_all
    Job.delete_all
    Communication.delete_all
    Organization.delete_all
    User.delete_all

    Rails.application.load_seed
  end

  task :owners => :environment do
    10.times do
      o = User.new
      o.role = 'Owner'
      o.first_name = Faker::Name.first_name
      o.last_name = Faker::Name.last_name
      o.email = "#{Faker::Internet.user_name}@example.com"
      o.password = 'testtest'
      o.organization_name = Faker::Company.name
      o.save
    end
  end

  task :crews => :environment do
    Crew.all.each {|c| c.destroy}
    40.times do
      c = Crew.new
      c.name = Faker::Lorem.word
      c.organization_id = Organization.offset(rand(Organization.count)).first.id
      c.save
    end
  end

  task :employees => :environment do
    User.where(:role => "Employee").all.each {|u| u.destroy}
    200.times do
      u = User.new
      u.organization_id = Organization.offset(rand(Organization.count)).first.id
      u.role = 'Employee'
      u.first_name = Faker::Name.first_name
      u.last_name = Faker::Name.last_name
      u.email = "#{Faker::Internet.user_name}@example.com"
      u.phone = Faker::PhoneNumber.phone_number
      u.password = 'testtest'
      u.address = Faker::Address.street_address
      u.state = Faker::Address.us_state
      u.city = Faker::Address.city
      u.zip = Faker::Address.zip_code
      u.pay_rate = rand(10..50)
      u.active                       = [true, false].sample
      u.can_view_leads               = [true, false].sample
      u.can_view_leads               = [true, false].sample
      u.can_manage_leads             = [true, false].sample
      u.can_view_appointments        = [true, false].sample
      u.can_manage_appointments      = [true, false].sample
      u.can_view_all_jobs            = [true, false].sample
      u.can_view_own_jobs            = [true, false].sample
      u.can_manage_jobs              = [true, false].sample
      u.can_view_all_proposals       = [true, false].sample
      u.can_view_assigned_proposals  = [true, false].sample
      u.can_manage_proposals         = [true, false].sample
      u.can_be_assigned_appointments = [true, false].sample
      u.can_be_assigned_jobs         = [true, false].sample
      u.save

      if [true, false].sample
        unless u.organization.crews.empty?
          crew = u.organization.crews.sample
          crew.users << u
          crew.save
        end
      end
    end
  end
  
  task :leads => :environment do
    Organization.all.each do |o|
      10.times do
        # Contact
        c = Contact.new
        c.first_name = Faker::Name.first_name
        c.last_name = Faker::Name.last_name
        c.phone = Faker::PhoneNumber.phone_number
        c.email = "#{Faker::Internet.user_name}@example.com"
        c.address = Faker::Address.street_address
        c.address2 = ""
        c.city = Faker::Address.city
        c.state = Faker::Address.us_state
        c.zip = Faker::Address.zip_code
        c.country = Faker::Address.country
        c.organization_id = o.id
        c.save
        
        # Job
        j = Job.new
        j.organization_id = o.id
        j.contact_id = c.id
        j.title = Faker::Lorem.words.join ' '
        j.lead_source_id = LeadSource.offset(rand(LeadSource.count)).first.id
        j.details = Faker::Lorem.paragraph
        j.probability = rand(0..100)
        j.state = "Lead"
        j.start_date = Time.zone.now + rand(30).days
        j.end_date = j.start_date + rand(20).days
        j.amount = rand(0..20000).to_f
        j.budgeted_hours = rand(0..100).to_f
        j.email_customer = [true, false].sample
        crews = Crew.where(:organization_id => o.id)
        j.crew_id = crews.offset(rand(crews.count)).first.id unless crews.empty?
        j.active = [true, false].sample
        j.save
        
        # Communications
        10.times do
          cm = Communication.new
          cm.organization_id = o.id
          cm.type = ['CommunicationRecord', 'PlannedCommunication'].sample
          cm.job_id = j.id
          cm.user_id = User.offset(rand(User.count)).first.id
          cm.note = Faker::Lorem.sentence
          cm.details = Faker::Lorem.paragraph
          cm.outcome = Communication::OUTCOMES[rand(Communication::OUTCOMES.count)]
          cm.action = Communication::ACTIONS[rand(Communication::ACTIONS.count)]
          cm.datetime = if cm.type == "CommunicationRecord"
            Time.at((Time.zone.now.to_f - 1.year.ago.to_f)*rand + 1.year.ago.to_f).to_datetime
          else
            Time.at((1.year.from_now.to_f - Time.zone.now.to_f)*rand + Time.zone.now.to_f).to_datetime
          end
          cm.datetime_exact = [true, false].sample
          cm.next_step = Communication::NEXT_STEPS[rand(Communication::NEXT_STEPS.count)]
          cm.save
        end
      end
    end
  end
end
