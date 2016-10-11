namespace :data do
  desc "Capitalize existing user names"
  task capitalize_user_names: :environment do
    User.find_each do |user|
      user.capitalize_names
      user.save
    end
    puts "User names have been capitalized in production. Delete this script."
  end
end
