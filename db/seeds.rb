# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Also see db/fixtures/*

LeadSource.create(name: 'Web Form', organization_id: 0, modifiable: false)
LeadSource.create(name: 'Referred by Friend', organization_id: 0)
LeadSource.create(name: 'Cold Call', organization_id: 0)

Quote.create(quote: "The greater danger for most of us lies not in setting our aim too high and falling short; but in setting our aim too low, and achieving our mark.", author: "Michelangelo")

error_temp = EmailTemplate.new({ "name"=>"email-parse-error", "subject"=>"“sorry, we couldn’t parse your email", "body"=>"", "enabled"=>true })
error_temp.without_versioning(:save)
success_temp = EmailTemplate.new({ "name"=>"email-parse-success", "subject"=>"we successfully parsed your email", "body"=>"", "enabled"=>true })
success_temp.without_versioning(:save)
